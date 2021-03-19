library(Covid19VaccineAesiIncidenceCharacterization)
targetCohortToCreateFile <- "settings/targetRef.csv"
targetCohorts <- readCsv(targetCohortToCreateFile)
targetCohorts$cohortType <- "target"

outcomeCohorts <- readCsv("settings/outcomeRef.csv")
outcomeCohortsToCreate <- outcomeCohorts[,c("outcomeId", "outcomeName", "fileName")]
names(outcomeCohortsToCreate) <- c("cohortId", "cohortName", "fileName")
outcomeCohortsToCreate$cohortType <- "outcome"

diagnosticsCohorts <- rbind(targetCohorts, outcomeCohortsToCreate)
names(diagnosticsCohorts)
diagnosticsCohorts$atlasId <- 100
names(diagnosticsCohorts) <- c("cohortId", "cohortName", "fileName", "cohortType", "atlasId")
diagnosticsCohorts$name <- tools::file_path_sans_ext(diagnosticsCohorts$fileName)
diagnosticsCohorts$cohortFullName <- diagnosticsCohorts$name


# Verify the package has all of the JSON required
diagnosticsCohortsColNames <- names(diagnosticsCohorts)
diagnosticsCohortsForPackage <- setNames(data.frame(matrix(ncol = length(diagnosticsCohortsColNames), nrow = 0), stringsAsFactors = FALSE), diagnosticsCohortsColNames)
for(i in 1:nrow(diagnosticsCohorts)) {
  jsonFile <- paste0(diagnosticsCohorts$name[i], ".json")
  jsonFileInPackage <- system.file("cohorts", jsonFile, package = "Covid19VaccineAesiIncidenceCharacterization")
  jsonExists <- file.exists(jsonFileInPackage)
  print(paste(jsonFile, " - In Package:", jsonExists))
  if (jsonExists && diagnosticsCohorts$name[i] != "HemorrhagicStroke") {
    diagnosticsCohortsForPackage <- rbind(diagnosticsCohortsForPackage, diagnosticsCohorts[i,])
  }
}

readr::write_csv(diagnosticsCohortsForPackage, file = "D:/git/ohdsi-studies/Covid19VaccineAesiIncidenceCharacterization/inst/settings/cohortsForDiagnostics.csv")
