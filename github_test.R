library(usethis)
?use_github

use_github(protocol = "https", auth_token = Sys.getenv("GITHUB_PAT"))

install.packages('repro')

usethis::create_github_token()

gitcreds::gitcreds_set()
