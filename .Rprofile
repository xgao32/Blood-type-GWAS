# Activate renv environment
if (file.exists("renv/activate.R")) {
    source("renv/activate.R")
}

# Source VS Code initialization script
init_file <- file.path(Sys.getenv(if (.Platform$OS.type == "windows") "USERPROFILE" else "HOME"), ".vscode-R", "init.R")
if (file.exists(init_file)) {
    source(init_file)
}