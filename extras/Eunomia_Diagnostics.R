# Please see code in extras/ProjectSetup.R to ensure
# you have installed and initialized "renv" for this
# project.
library(Covid19VaccineAesiIncidenceCharacterization)

# Specify where the temporary files (used by the Andromeda package) will be created:
andromedaTempFolder <- if (Sys.getenv("ANDROMEDA_TEMP_FOLDER") == "") "~/andromedaTemp" else Sys.getenv("ANDROMEDA_TEMP_FOLDER")
options(andromedaTempFolder = andromedaTempFolder)

# Define a schema that can be used to emulate temp tables:
tempEmulationSchema <- NULL
minCellCount <- 5

connectionDetails <- Eunomia::getEunomiaConnectionDetails()
# Details specific to the database:
databaseId <- "EUNOMIA"
databaseName <- "EUNOMIA"
databaseDescription <- "EUNOMIA"

# Details for connecting to the CDM and storing the results
cdmDatabaseSchema <- "main"
cohortDatabaseSchema <- "main"
cohortTable <- "AS_18MAR2021_AESI_Diag"

# Set the folder for holding the study output
projectRootFolder <- "D:/Covid19VaccineAesiIncidenceCharacterization/Runs"
outputFolder <- file.path(projectRootFolder, databaseId)
if (!dir.exists(outputFolder)) {
  dir.create(outputFolder, recursive = TRUE)
}
setwd(outputFolder)

executeCohortDiagnostics(connectionDetails = connectionDetails,
                         cdmDatabaseSchema = cdmDatabaseSchema,
                         cohortDatabaseSchema = cohortDatabaseSchema,
                         cohortTable = cohortTable,
                         tempEmulationSchema = tempEmulationSchema,
                         exportFolder = outputFolder,
                         databaseId = databaseId,
                         databaseName = databaseName,
                         databaseDescription = databaseDescription,
                         minCellCount = minCellCount)

#unlink("D:/Covid19VaccineAesiIncidenceCharacterization/Runs/EUNOMIA/diagnostics", recursive = T)

