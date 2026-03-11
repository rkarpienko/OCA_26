# =============================================================================
# Online Content Analysis – Lecture 1
# Topic: Introduction to Strings and Text Manipulation in R
# =============================================================================
# This script accompanies Lecture 1. It shows how R handles text (strings),
# introduces key string functions, and explores a real product-review dataset.
#
# As a marketing or business analyst, you will often work with large volumes of
# text: customer reviews, social media posts, survey answers, etc. Before you
# can analyse that text you need to understand how R stores and manipulates it.
# =============================================================================


# -----------------------------------------------------------------------------
# 1. STRINGS AND THE CHARACTER DATA TYPE
# -----------------------------------------------------------------------------
# In R, any piece of text – a letter, a word, a sentence – is called a
# "string" and belongs to the "character" class.
# Strings are always written between quotation marks ("...").
#
# The <- symbol is the assignment operator: it stores a value in a variable.
# Think of a variable as a labelled drawer where you keep information.

# An empty string: a character variable that contains no text at all.
# It still belongs to the character class – like an empty but labelled drawer.
empty_string <- ""
empty_string          # prints: ""
class(empty_string)   # prints: "character"


# character(length = 0) creates a character vector with ZERO elements.
# Unlike the empty string above (which IS one element, just with no content),
# this vector has nothing in it at all.
empty_character <- character(length = 0)
empty_character        # prints: character(0)
class(empty_character) # prints: "character"


# -----------------------------------------------------------------------------
# 2. CHARACTER VECTORS
# -----------------------------------------------------------------------------
# A vector is an ordered collection of elements of the SAME type.
# character(10) creates a character vector with 10 slots, all pre-filled
# with empty strings "". This is called "initialising" a vector.
character_vector <- character(10)
character_vector   # 10 empty strings: "" "" "" "" "" "" "" "" "" ""

# We can fill individual slots using square-bracket indexing.
# Index [5] refers to the 5th position, [3] to the 3rd, and so on.
# Note: R starts counting from 1, not 0 (unlike many other languages).
character_vector[5] <- "fifth"
character_vector[3] <- "mooooooooooooi"
character_vector   # positions 3 and 5 now contain text; the rest stay empty


# -----------------------------------------------------------------------------
# 3. COMBINING STRINGS WITH paste()
# -----------------------------------------------------------------------------
# paste() joins (concatenates) two or more strings into one.
#
# Key arguments:
#   sep      – the character(s) placed BETWEEN the pieces being joined
#   collapse – if you pass a vector, this character is placed BETWEEN elements
#              to collapse the whole vector into a single string

# Joining two phrases with " , " as a separator:
x <- paste("My favorite book", "has many chapters", sep = " , ")
x   # "My favorite book , has many chapters"

# paste("Chapter", 1:5, ...) recycles "Chapter" across the numbers 1 to 5,
# producing five separate "Chapter.1", "Chapter.2", ... strings.
# collapse = ", " then collapses all five into ONE single string.
chapters <- paste("Chapter", 1:5, sep = ".", collapse = ", ")
chapters   # "Chapter.1, Chapter.2, Chapter.3, Chapter.4, Chapter.5"


# -----------------------------------------------------------------------------
# 4. LOADING THE PRODUCT REVIEWS DATASET
# -----------------------------------------------------------------------------
# We work with a real dataset of Amazon product reviews stored in a CSV file.
# CSV (Comma-Separated Values) is one of the most common formats for tabular data.
#
# options(stringsAsFactors = FALSE) tells R to keep text columns as plain
# character strings instead of converting them to "factors" (a categorical
# type). This is important for text analysis – we want raw strings.
#
# IMPORTANT: The CSV file must be in your WORKING DIRECTORY.
# Check where R is looking with getwd(), and change it with setwd() or via
# Session > Set Working Directory in RStudio.

options(stringsAsFactors = FALSE)
prodreviews <- read.csv("Product Reviews.csv")  # load the full dataset

# Extract just the Title column and convert it to a character vector.
# $ is R's way of selecting a specific column from a data frame.
prodtitle <- as.character(prodreviews$Title)

# set.seed() fixes the random number generator so that the 20 titles chosen
# by sample() are the same every time anyone runs this script (reproducibility).
set.seed(123)
(prodtitle20 <- sample(prodtitle, 20))  # randomly select 20 titles
# The outer parentheses ( ) are a shortcut: they assign AND print the result.


# -----------------------------------------------------------------------------
# 5. BASIC STRING OPERATIONS ON THE SAMPLE OF 20 TITLES
# -----------------------------------------------------------------------------

# --- substr(): extract a portion of each string ---
# substr(x, start, stop) keeps only the characters from position "start"
# to position "stop" in each element of x.
# Here we keep just the first 4 characters of every title.
# Useful for quick comparisons or building short codes from longer strings.
substr(prodtitle20, start = 1, stop = 4)

# --- abbreviate(): create unique short labels ---
# abbreviate() shortens each string to a minimum number of characters while
# guaranteeing that the results are UNIQUE across the whole vector.
# It typically picks the first letter of each word.
# Useful when you need compact but distinguishable labels (e.g. for plots).
abbreviate(prodtitle20)


# -----------------------------------------------------------------------------
# 6. MEASURING STRING LENGTHS WITH nchar()
# -----------------------------------------------------------------------------
# nchar() counts how many characters (letters, spaces, punctuation, etc.)
# are in each string. This is a simple but revealing statistic:
# "How much did customers write about a product?" starts with string length.

nchar(prodtitle20)              # vector of lengths for all 20 titles
max(nchar(prodtitle20))         # the length of the longest title in the sample

# which() returns the INDEX (position) of elements that satisfy a condition.
# Here: which titles have a length equal to the maximum length?
# We then use that index to retrieve the actual title strings.
prodtitle20[which(nchar(prodtitle20) == max(nchar(prodtitle20)))]


# -----------------------------------------------------------------------------
# 7. EXPLORING THE FULL DATASET
# -----------------------------------------------------------------------------

# How many product titles are in the full dataset?
length(prodtitle)          # total number of titles (including duplicates)

# How many of those titles are unique (i.e. not repeated)?
# Comparing these two numbers tells you how many duplicate titles exist.
length(unique(prodtitle))

# summary() on a numeric vector gives the five-number summary + mean.
# nchar(prodtitle) converts every title to its character count, so summary()
# here tells us: what is the typical title length? min? max? median?
summary(nchar(prodtitle))


# -----------------------------------------------------------------------------
# 8. VISUALISING THE DISTRIBUTION OF TITLE LENGTHS
# -----------------------------------------------------------------------------
# A histogram shows how many strings fall into each "bin" of character lengths.
# This answers: "Are product titles mostly short, long, or somewhere in between?"
# breaks = 20 requests about 20 bins (R may adjust this slightly).

hist(nchar(prodtitle),
     main   = "Histogram of the Titles length",
     breaks = 20,
     xlab   = "Number of characters in each string",
     ylab   = "Number of titles with the same length")
