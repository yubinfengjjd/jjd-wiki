wf_prepare_spacexr_vendor <- function(cfg) {
  vendor_dir <- file.path(cfg$project_root, "code", "vendor", "spacexr_patched")
  src <- cfg$deps$spacexr_source
  if (!dir.exists(src)) return(NULL)
  if (!dir.exists(vendor_dir)) {
    dir.create(vendor_dir, recursive = TRUE, showWarnings = FALSE)
    files <- list.files(src, recursive = TRUE, full.names = TRUE, all.files = TRUE, no.. = TRUE)
    for (f in files) {
      rel <- substring(f, nchar(src) + 2L)
      out <- file.path(vendor_dir, rel)
      if (dir.exists(f)) dir.create(out, recursive = TRUE, showWarnings = FALSE) else {
        dir.create(dirname(out), recursive = TRUE, showWarnings = FALSE)
        file.copy(f, out, overwrite = TRUE)
      }
    }
  }
  desc <- file.path(vendor_dir, "DESCRIPTION")
  if (file.exists(desc)) {
    txt <- readLines(desc, warn = FALSE)
    txt <- gsub("\\bRfast,\\s*", "", txt)
    txt <- gsub("\\s+Rfast\\s*$", "", txt)
    txt <- txt[!(trimws(txt) == "" & c(FALSE, head(grepl("^Imports:", txt), -1)))]
    txt <- txt[!(grepl("^\\s*$", txt) & seq_along(txt) > 1L & grepl("^\\s*$", c("", txt[-length(txt)])))]
    writeLines(txt, desc)
  }
  vendor_dir
}
