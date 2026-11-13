infer_species <- function(genes) {
  genes <- genes[!is.na(genes) & grepl("[A-Za-z]", genes)]
  if (!length(genes)) return("human")
  letters_only <- gsub("[^A-Za-z]", "", genes)
  human_like <- mean(letters_only == toupper(letters_only))
  mouse_like <- mean(grepl("^[A-Z][a-z]+", genes))
  if (human_like >= mouse_like) "human" else "mouse"
}
