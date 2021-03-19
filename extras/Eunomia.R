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
cohortTablePrefix <- "AS_7MAR2021_AESI_"

# Set the folder for holding the study output
projectRootFolder <- "D:/Covid19VaccineAesiIncidenceCharacterization/Runs"
outputFolder <- file.path(projectRootFolder, databaseId)
if (!dir.exists(outputFolder)) {
  dir.create(outputFolder, recursive = TRUE)
}
setwd(outputFolder)

# Use this to run the study. The results will be stored in a zip file called
# 'Results_<databaseId>.zip in the outputFolder.
runStudy(connectionDetails = connectionDetails,
         cdmDatabaseSchema = cdmDatabaseSchema,
         cohortDatabaseSchema = cohortDatabaseSchema,
         cohortTablePrefix = cohortTablePrefix,
         tempEmulationSchema = tempEmulationSchema,
         exportFolder = outputFolder,
         databaseId = databaseId,
         databaseName = databaseName,
         databaseDescription = databaseDescription,
         incremental = TRUE,
         minCellCount = minCellCount)


# For uploading the results. You should have received the key file from the study coordinator:
keyFileName <- "E:/Covid19VaccineAesiIncidenceCharacterization/study-data-site-covid19.dat"
userName <- "study-data-site-covid19"

# When finished with reviewing the diagnostics, use the next command to upload the diagnostic results
# uploadDiagnosticsResults(outputFolder, keyFileName, userName)


# When finished with reviewing the results, use the next command upload study results to OHDSI SFTP
# server: uploadStudyResults(outputFolder, keyFileName, userName)
