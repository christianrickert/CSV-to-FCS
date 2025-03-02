# CSV to FCS
    # Converting .csv file data into an .fcs file
    # Thomas Ashhurst (2017-09-13) [github.com/sydneycytometry]
    # *adapted from [https://gist.github.com/yannabraham/c1f9de9b23fb94105ca5]

# Code refactoring by Christian Rickert (2022-03-31)

# Install required packages
if(!requireNamespace("BiocManager", quietly = TRUE)) {install.packages("BiocManager", quiet = TRUE)}
if(!require('flowCore')) {BiocManager::install("flowCore", update = FALSE)}
if(!require('Biobase')) {BiocManager::install("Biobase", update = FALSE)}
if(!require('data.table')) {install.packages('data.table')}
if(!require('rstudioapi')) {install.packages('rstudioapi')}

# Load packages
library('flowCore')
library('Biobase')
library('data.table')
library('rstudioapi')

# Set input and output variables
currentFolder <- dirname(rstudioapi::getSourceEditorContext()$path)  # script location
importFolder <- file.path(currentFolder, "import", fsep = .Platform$file.sep)  # relative path
exportFolder <- file.path(currentFolder, "export", fsep = .Platform$file.sep)
filePattern  <- "\\.csv$"  # match file extension (case-insensitive)

# Set up working directories
if (!file.exists(importFolder)) {dir.create(importFolder)}
print(paste("Input folder: ", importFolder))
if (!file.exists(exportFolder)) {dir.create(exportFolder)}
print(paste("Export folder: ", exportFolder))

# Get list of input files
FileNames <- list.files(path = importFolder, pattern = filePattern, ignore.case = TRUE)

# Read data from CSV and write FCS data
for (File in FileNames) {
  print(File)

  setwd(importFolder)
  FileData <- fread(file = File, check.names = FALSE)
  metadata <- data.frame(name = dimnames(FileData)[[2]], desc = paste('column', dimnames(FileData)[[2]], 'from dataset'))
  metadata$minRange <- apply(FileData, 2, min)
  metadata$maxRange <- apply(FileData, 2, max)

  setwd(exportFolder)
  FileData.ff <- new("flowFrame", exprs = as.matrix(FileData), parameters = AnnotatedDataFrame(metadata))
  write.FCS(FileData.ff, paste0(File, ".fcs"))
}
