#' @export
executeCohortDiagnostics <- function(connectionDetails = NULL,
                                 connection = NULL,
                                 cdmDatabaseSchema,
                                 cohortDatabaseSchema = cdmDatabaseSchema,
                                 cohortTable = "AESI_diagnostics",
                                 tempEmulationSchema = NULL,
                                 cohortIdsToExcludeFromExecution = c(),
                                 exportFolder,
                                 databaseId = "Unknown",
                                 databaseName = "Unknown",
                                 databaseDescription = "Unknown",
                                 minCellCount = 5) {
  # NOTE: The exportFolder is the root folder where the
  # study results will live. The diagnostics will be written
  # to a subfolder called "diagnostics". Both the diagnostics
  # and main study code (RunStudy.R) will share the same
  # RecordKeeping folder so that we can ensure that cohorts
  # are only created one time.
  diagnosticOutputFolder <- file.path(exportFolder, "diagnostics")
  if (!file.exists(diagnosticOutputFolder)) {
    dir.create(diagnosticOutputFolder, recursive = TRUE)
  }
  incrementalFolder = file.path(diagnosticOutputFolder, "RecordKeeping")
  if (!file.exists(incrementalFolder)) {
    dir.create(incrementalFolder, recursive = TRUE)
  }
  
  if (!is.null(getOption("andromedaTempFolder")) && !file.exists(getOption("andromedaTempFolder"))) {
    warning("andromedaTempFolder '",
            getOption("andromedaTempFolder"),
            "' not found. Attempting to create folder")
    dir.create(getOption("andromedaTempFolder"), recursive = TRUE)
  }

  ParallelLogger::clearLoggers()  # Ensure that any/all previous logging activities are cleared
  ParallelLogger::addDefaultFileLogger(file.path(diagnosticOutputFolder, "cohortDiagnosticsLog.txt"))
  ParallelLogger::addDefaultErrorReportLogger(file.path(exportFolder, paste0(getThisPackageName(),
                                                                             "ErrorReportR.txt")))
  ParallelLogger::addDefaultConsoleLogger()
  on.exit(ParallelLogger::unregisterLogger("DEFAULT_FILE_LOGGER", silent = TRUE))
  on.exit(ParallelLogger::unregisterLogger("DEFAULT_ERRORREPORT_LOGGER", silent = TRUE), add = TRUE)
  on.exit(ParallelLogger::unregisterLogger("DEFAULT_CONSOLE_LOGGER", silent = TRUE), add = TRUE)
  on.exit(ParallelLogger::unregisterLogger("DEFAULT"))

  # Write out the system information
  ParallelLogger::logInfo(.systemInfo())
  
  if (is.null(connection)) {
    connection <- DatabaseConnector::connect(connectionDetails)
    on.exit(DatabaseConnector::disconnect(connection))
  }

  # Run diagnostics -----------------------------
  cohortsForDiagnosticsFile <- "settings/cohortsForDiagnostics.csv"
  cohorts <- readCsv(cohortsForDiagnosticsFile)
  cohorts <- cohorts[!(cohorts$cohortId %in% cohortIdsToExcludeFromExecution), ]
  ParallelLogger::logInfo("Running cohort diagnostics")
  CohortDiagnostics::instantiateCohortSet(connectionDetails = connectionDetails,
                                          connection = connection, 
                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                          oracleTempSchema = tempEmulationSchema,
                                          cohortDatabaseSchema = cohortDatabaseSchema,
                                          cohortTable = cohortTable,
                                          cohortIds = cohorts$cohortId,
                                          packageName = getThisPackageName(),
                                          cohortToCreateFile = cohortsForDiagnosticsFile,
                                          createCohortTable = TRUE,
                                          incremental = TRUE,
                                          incrementalFolder = incrementalFolder)
  CohortDiagnostics::runCohortDiagnostics(packageName = getThisPackageName(),
                                          connection = connection,
                                          cohortToCreateFile = cohortsForDiagnosticsFile,
                                          connectionDetails = connectionDetails,
                                          cdmDatabaseSchema = cdmDatabaseSchema,
                                          oracleTempSchema = tempEmulationSchema,
                                          cohortDatabaseSchema = cohortDatabaseSchema,
                                          cohortTable = cohortTable,
                                          cohortIds = cohorts$cohortId,
                                          inclusionStatisticsFolder = diagnosticOutputFolder,
                                          exportFolder = diagnosticOutputFolder,
                                          databaseId = databaseId,
                                          databaseName = databaseName,
                                          databaseDescription = databaseDescription,
                                          runInclusionStatistics = FALSE,
                                          runIncludedSourceConcepts = TRUE,
                                          runOrphanConcepts = TRUE,
                                          runTimeDistributions = TRUE,
                                          runBreakdownIndexEvents = TRUE,
                                          runIncidenceRate = TRUE,
                                          runCohortOverlap = FALSE,
                                          runCohortCharacterization = FALSE,
                                          minCellCount = minCellCount,
                                          incremental = TRUE,
                                          incrementalFolder = incrementalFolder)

  # Bundle the diagnosics for export
  bundledResultsLocation <- bundleDiagnosticsResults(diagnosticOutputFolder, databaseId)
  ParallelLogger::logInfo(paste("AESI cohort diagnostics are bundled for sharing at: ", bundledResultsLocation))
}

#' @export
bundleDiagnosticsResults <- function(diagnosticOutputFolder, databaseId) {
  zipName <- file.path(diagnosticOutputFolder, paste0("Results_diagnostics_", databaseId, ".zip"))  
  files <- list.files(diagnosticOutputFolder, "^Results_.*.zip$", full.names = TRUE, recursive = TRUE)
  oldWd <- setwd(diagnosticOutputFolder)
  on.exit(setwd(oldWd), add = TRUE)
  DatabaseConnector::createZipFile(zipFile = zipName, files = files)
  return(zipName)
}