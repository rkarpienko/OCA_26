# =============================================================================
# Online Content Analysis – Lecture 2
# Topic: Regular Expressions (RegExp) in R
# =============================================================================
# Regular expressions (regexp) are a powerful language for searching,
# matching, and replacing patterns inside text.
#
# Why does this matter for marketing/business analysts?
# Imagine you have 50,000 product reviews and you want to find all the ones
# that mention a price, an email address, or a rating like "4 out of 5".
# Writing a regexp lets you do that in one line instead of reading each review
# manually. Search engines and word processors use the same technology.
#
# A regexp is a compact string of characters and special symbols that
# describes a pattern. For example: "^Ki" means "starts with Ki".
# =============================================================================


# -----------------------------------------------------------------------------
# 1. VISUALISING REGULAR EXPRESSIONS (re2r package)
# -----------------------------------------------------------------------------
# The re2r package produces a visual diagram of a regexp pattern, which is
# very helpful when learning because regexp syntax can look cryptic at first.
#
# re2r is not on CRAN (R's main package repository), so we install it from
# GitHub using the devtools package.
# Run these install lines ONCE. After that, just use library(re2r).

install.packages("re2r")      # attempt CRAN install (may not be available)
install.packages("devtools")  # devtools lets us install packages from GitHub
library(devtools)

install_github("qinwf/re2r")  # install re2r directly from its GitHub repo

library(re2r)

# --- Example 1: pattern for an e-mail address ---
# This regexp matches email addresses like john.doe@someserver.com
# Reading it piece by piece:
#   \\b               – word boundary: match must start/end at a word edge
#   [a-zA-Z0-9._%+-]+ – one or more characters that can appear in a username
#                       (letters, digits, dot, underscore, %, +, -)
#   @                 – the literal @ symbol every email must have
#   [a-zA-Z0-9.-]+    – the domain name (e.g. gmail, outlook)
#   \\.               – a literal dot (the . must be escaped with \\)
#   [a-zA-Z]{5,9}     – the top-level domain, between 5 and 9 letters long
#   \\b               – closing word boundary
show_regex("\\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{5,9}\\b")

# --- Example 2: pattern for a rating such as "4 out of 5" ---
# [0-9]+    – one or more digits (the rating, e.g. 4)
# \\B       – non-word boundary (the number runs directly into the next part)
# (out of)  – the literal phrase "out of"
# \\B       – non-word boundary before the second number
# [0-9]     – a single digit (the scale, e.g. 5)
# .*        – any characters that follow
show_regex("[0-9]+\\B(out of)\\B[0-9].*")

# Reference: https://github.com/qinwf/re2r
# In-class exercises: try re2_detect(), re2_match(), re2_match_all(),
# re_replace(), re2_extract() from re2r applied to a vector of email strings.


# -----------------------------------------------------------------------------
# 2. QUANTIFIERS — how many times should a character repeat?
# -----------------------------------------------------------------------------
# Quantifiers control how many times the preceding character (or group)
# must appear for the pattern to match.
#
# Summary table:
#   *      matches 0 or more times  (zero, one, or many)
#   +      matches 1 or more times  (at least once)
#   ?      matches 0 or 1 time      (optional – may or may not be there)
#   {n}    matches exactly n times
#   {n,}   matches at least n times
#   {n,m}  matches between n and m times (inclusive)
#
# We demonstrate all of these on a simple test vector where the only
# difference between strings is how many "z"s appear between "x" and "y".

strings <- c("x", "xy", "xz", "xzy", "xzzy", "xzzzy", "xzzzzy")

# grep() searches for a pattern inside a vector of strings.
# By default it returns the INDEX (position) of each match.
# Setting value = TRUE returns the ACTUAL matching strings instead.

# Without value = TRUE → returns positions (indices)
grep("xy", strings)             # only position 2 ("xy") matches

# With value = TRUE → returns the matching strings themselves
grep("xy", strings, value = TRUE)    # "xy"

# * (zero or more z's between x and y)
# Matches "xy" (zero z's), "xzy", "xzzy", "xzzzy", "xzzzzy"
grep("xz*y", strings, value = TRUE)

# + (one or more z's between x and y)
# "xy" is NOT matched because there is no z at all.
grep("xz+y", strings, value = TRUE)

# ? (zero or one z between x and y)
# Matches only "xy" and "xzy" – two or more z's and the match fails.
grep("xz?y", strings, value = TRUE)

# {3} (exactly 3 z's)
# Only "xzzzy" qualifies.
grep("xz{3}y", strings, value = TRUE)

# {2,} (at least 2 z's, no upper limit)
# Matches "xzzy", "xzzzy", "xzzzzy".
grep("xz{2,}y", strings, value = TRUE)

# {0,2} (between 0 and 2 z's, inclusive)
# Matches "xy", "xzy", "xzzy".
grep("xz{0,2}y", strings, value = TRUE)


# -----------------------------------------------------------------------------
# 3. LOAD THE PRODUCT REVIEWS DATASET
# -----------------------------------------------------------------------------
# Same dataset as Lecture 1; we use set.seed(3) this time so we get a
# DIFFERENT random sample of 20 titles than in Lecture 1.
# This lets us see new patterns while keeping results reproducible.

options(stringsAsFactors = FALSE)
prodreviews <- read.csv("Product Reviews.csv")
prodtitle   <- as.character(prodreviews$Title)
set.seed(3)
(prodtitle20 <- sample(prodtitle, 20))


# -----------------------------------------------------------------------------
# 4. ANCHORS AND BOUNDARIES — WHERE in the string should the match occur?
# -----------------------------------------------------------------------------
# Anchors fix the match to a position in the string.
# They do not consume a character – they match a LOCATION.
#
#   ^    start of the string
#   $    end of the string
#   \\b  word boundary: the edge between a word character and a non-word char
#        (e.g. the gap between a space and a letter, or start/end of the string)
#   \\B  non-word boundary: opposite of \\b (the match is inside a word)
#
# NOTE: In R, a single backslash \ must be written as \\ inside strings.
# So the regexp symbol \b (word boundary) is written "\\b" in R code.

# ^ anchor: find titles that START with "Ki" (e.g. "Kindle ...")
grep("^Ki", prodtitle20, value = TRUE)

# $ anchor: find titles that END with "on" (e.g. "...Amazon")
grep("on$", prodtitle20, value = TRUE)

# \\b word boundary: find "Fire" as a STANDALONE word.
# "\\bFire\\b" matches "Kindle Fire" but NOT "Firefox" or "Crossfire",
# because in those cases "Fire" does not sit between two word boundaries.
grep("\\bFire\\b", prodtitle20, value = TRUE)

# \\B non-word boundary: find "able" only when it appears INSIDE another word
# (e.g. "readable", "capable"). It will NOT match "able" standing alone,
# nor "able." where the dot after it breaks the word boundary condition.
grep("\\Bable\\B", prodtitle20, value = TRUE)


# -----------------------------------------------------------------------------
# 5. COMMON OPERATORS — what characters are we looking for?
# -----------------------------------------------------------------------------

# --- Dot (.) : wildcard, matches ANY single character ---
# "re." matches "re" followed by any character: "rea", "ret", "re ", etc.
# Useful when you don't care what the next character is.
grep("re.", prodtitle20, value = TRUE)

# --- Square brackets [...] : character list or range ---
# Matches exactly ONE character from the set defined inside the brackets.

# "k[ae]" → k followed by either a or e
grep("k[ae]", prodtitle20, value = TRUE)

# "k[a-y]" → k followed by any letter from a to y (a whole range in one go)
grep("k[a-y]", prodtitle20, value = TRUE)

# --- Negated brackets [^...] : match anything EXCEPT what is listed ---
# NOTE: ^ inside brackets means "NOT". This is different from ^ as an anchor!
# "f[^i]" → f followed by any character that is NOT i
# Compare with "fi" which requires an i after the f.
grep("f[^i]", prodtitle20, value = TRUE)   # f NOT followed by i
grep("fi",    prodtitle20, value = TRUE)   # f followed by i

# --- OR operator | : match either the left OR the right pattern ---
# "ae|ea" → strings containing either "ae" or "ea" anywhere inside them.
grep("ae|ea", prodtitle20, value = TRUE)

# --- Capturing parentheses (...) : group characters into a unit ---
# The group can be referenced later (see gsub below) via backreferences \\1, \\2, ...
# Here, "(ire)" simply matches the sequence "ire" (same result as without
# parentheses in this case, but the group is saved for potential reuse).
grep("(ire)", prodtitle20, value = TRUE)

# --- gsub() with backreferences: search AND replace using captured groups ---
# gsub()  = "global substitution": replaces ALL occurrences in each string.
# (sub()  would replace only the FIRST occurrence per string.)
#
# Pattern:      "(Kindle) Fire"
#   (Kindle)    – group 1: captures the word "Kindle" and remembers it
#    Fire       – the word right after (not captured, will be replaced)
#
# Replacement:  "\\1 Big Fire"
#   \\1         – backreference: re-inserts the captured group 1 ("Kindle")
#    Big Fire   – the new text that replaces " Fire"
#
# Net result: "Kindle Fire" → "Kindle Big Fire"
# "Kindle" stays unchanged because \\1 puts it back; only "Fire" is swapped.
gsub("(Kindle) Fire", "\\1 Big Fire", prodtitle20)

# --- Escaping special characters with \\ ---
# In a regexp the dot . is a wildcard (matches anything).
# To search for a LITERAL dot (e.g. a period in "2nd Ed."), escape it: \\.
grep("\\.", prodtitle20, value = TRUE)


# -----------------------------------------------------------------------------
# 6. CHARACTER CLASSES — predefined sets of characters
# -----------------------------------------------------------------------------
# Instead of writing [a-zA-Z0-9] manually, R provides named character classes.
# Syntax: [[:classname:]] — note the double square brackets, they are required.
#
# Most useful classes for text analysis:
#   [[:alpha:]]  – any letter (a–z, A–Z)
#   [[:digit:]]  – any digit (0–9)
#   [[:alnum:]]  – any letter or digit
#   [[:lower:]]  – lowercase letters only
#   [[:upper:]]  – uppercase letters only
#   [[:punct:]]  – punctuation (! ? . , ; : " ' - etc.)
#   [[:space:]]  – whitespace (space, tab, newline, etc.)
#   [[:blank:]]  – space and tab only
#
# For a business analyst, [[:punct:]] is handy to spot titles with
# exclamation marks or other emotional punctuation in reviews.

# Find all titles in the sample that contain ANY punctuation character.
grep("[[:punct:]]", prodtitle20, value = TRUE)

# -----------------------------------------------------------------------------
# EXERCISE HINTS (from Exercises 2 – try these yourself)
# -----------------------------------------------------------------------------
# Exercise 1: Find titles with the pattern "ire". Then explore other patterns
#             using the quantifiers above on prodtitle20.
#
# Exercise 2: From prodtitle (full dataset), find titles containing "love"
#             that end with "!". Then replace "!" with "?" using gsub()
#             and a backreference.
#             Hint: pattern = "(love.*)(!)$", replacement = "\\1?"
#
# Exercise 3: On the full prodtitle dataset:
#             - Find titles with two consecutive digits.
#               Hint: [[:digit:]]{2}
#             - Find titles with non-word characters.
#               Hint: \\W  (equivalent to [^A-Za-z0-9_])