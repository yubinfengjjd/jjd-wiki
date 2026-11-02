# SCP 0.5.6 commit b9b0eb7a | source R/RcppExports.R:4-6
# sha256(func-block)=0806d6c1332ffcfa38abe039b4b72d43907d7354e7d9fe4e19cdb40846b09618
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
asMatrix <- function(rp, cp, z, nrows, ncols) {
    .Call('_SCP_asMatrix', PACKAGE = 'SCP', rp, cp, z, nrows, ncols)
}
