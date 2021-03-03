# Copyright 2021 Observational Health Data Sciences and Informatics
#
# This file is part of Covid19VaccineAesiIncidenceCharacterization19VaccineAesiIncidenceCharacterization
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Format and check code ---------------------------------------------------
OhdsiRTools::formatRFolder()
OhdsiRTools::updatePackageNameFolder(packageName = "Covid19VaccineAesiIncidenceCharacterization", recursive = T)
OhdsiRTools::checkUsagePackage("Covid19VaccineAesiIncidenceCharacterization")
OhdsiRTools::updateCopyrightYearFolder()
devtools::document()
Sys.setenv(JAVA_HOME = "")
devtools::check()

# Create manual -----------------------------------------------------------
unlink("extras/Covid19VaccineAesiIncidenceCharacterization.pdf")
shell("R CMD Rd2pdf ./ --output=extras/Covid19VaccineAesiIncidenceCharacterization.pdf")

pkgdown::build_site()

# Store environment in which the study was executed -----------------------
OhdsiRTools::insertEnvironmentSnapshotInPackage("Covid19VaccineAesiIncidenceCharacterization")

# Check all files for UTF-8 Encoding and ensure there are no non-ASCII characters
OhdsiRTools::findNonAsciiStringsInFolder()

packageFiles <- list.files(path = ".", recursive = TRUE)
if (!all(utf8::utf8_valid(packageFiles))) {
  print("Found invalid UTF-8 encoded files")
}

# Create the Renv lock file
OhdsiRTools::createRenvLockFile("Covid19VaccineAesiIncidenceCharacterization")

# Validate cohort SQL file names ------------
targetCohorts <- Covid19VaccineAesiIncidenceCharacterization::readCsv("settings/targetRef.csv")
targetCohorts$cohortFolder <- "target"
subgroupCohorts <- Covid19VaccineAesiIncidenceCharacterization::readCsv("settings/subgroupRef.csv")
subgroupCohorts$cohortFolder <- "subgroup"
outcomeCohorts <- Covid19VaccineAesiIncidenceCharacterization::readCsv("settings/outcomeRef.csv")
outcomeCohorts$cohortFolder <- "outcome"
# Reformat the outcomeCohorts dataframe to match target/subgroup
outcomeCohortsReformatted <- outcomeCohorts[,c("outcomeId", "outcomeName", "fileName", "cohortFolder")]
names(outcomeCohortsReformatted) <- c("cohortId", "cohortName", "fileName", "cohortFolder") 
allCohorts <- rbind(targetCohorts, subgroupCohorts, outcomeCohortsReformatted)

# Obtain the list of SQL files in the list
packageSqlFiles <- list.files(system.file(file.path("sql/sql_server/"), package="Covid19VaccineAesiIncidenceCharacterization"), recursive = TRUE)

for (i in 1:nrow(allCohorts)) {
  # Verify that the path to the SQL file is correct and matches
  # with case sensitivity
  sqlFileName <- file.path(allCohorts$cohortFolder[i], allCohorts$fileName[i])
  fileFound <- sqlFileName %in% packageSqlFiles
  if (!fileFound) {
    warning(paste(sqlFileName, "not found in package. This is likely due to a difference in case sensitivity."))
  }
}
