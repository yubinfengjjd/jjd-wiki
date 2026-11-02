# SCP 0.5.6 commit b9b0eb7a | source R/SCP-plot.R:1076-1094
# sha256(func-block)=99c268bb3a88ebb783f9a897487665458376cc05781878101a5c24aed49e927e
# derived copy (SCP:: strip/system.file repoint); verbatim original in coverage/extracted
BlendRGBList <- function(Clist, mode = "blend", RGB_BackGround = c(1, 1, 1)) {
  N <- length(Clist)
  ClistUse <- Clist
  while (N != 1) {
    temp <- ClistUse
    ClistUse <- list()
    for (C in temp[1:(length(temp) - 1)]) {
      c1 <- C[[1]]
      a1 <- C[[2]]
      c2 <- temp[[length(temp)]][[1]]
      a2 <- temp[[length(temp)]][[2]]
      ClistUse <- append(ClistUse, list(Blend2Color(C1 = list(c1, a1 * (1 - 1 / N)), C2 = list(c2, a2 * 1 / N), mode = mode)))
    }
    N <- length(ClistUse)
  }
  Result <- list(ClistUse[[1]][[1]], ClistUse[[1]][[2]])
  Result <- RGBA2RGB(Result, BackGround = RGB_BackGround)
  return(Result)
}
