# 🧬 NGS Lab Notes

A collection of Linux, R Programming, and Bioinformatics commands used during the **Next Generation Sequencing (NGS) Laboratory** sessions.

---

# 📚 Table of Contents

- Linux Commands
- File Management
- Text Processing
- Lab Practice Questions
- R Programming
- Bioinformatics Tools
- Useful Tips

---

# 🐧 Linux Commands

## Directory Navigation

| Command | Description |
|----------|-------------|
| `pwd` | Print current working directory |
| `ls` | List files and directories |
| `ls -l` | Detailed file listing |
| `ls -lh` | Human-readable file sizes |
| `ls -la` | Show hidden files |
| `cd directory` | Change directory |
| `cd ..` | Move to parent directory |
| `mkdir folder` | Create a directory |
| `rm file` | Remove a file |
| `rm -r folder` | Remove directory recursively |
| `tree` | Display directory structure |

---

# 📂 File Operations

| Command | Description |
|----------|-------------|
| `cat file.txt` | Display file contents |
| `less file.txt` | View large files page by page |
| `head file.txt` | Show first 10 lines |
| `head -3 file.txt` | Show first 3 lines |
| `tail file.txt` | Show last 10 lines |
| `wc -l file.txt` | Count lines |
| `wc -w file.txt` | Count words |
| `wc -c file.txt` | Count characters (bytes) |

---

# 📦 Working with Compressed Files

| Command | Description |
|----------|-------------|
| `gzip file` | Compress a file |
| `gunzip file.gz` | Uncompress a file |
| `zcat file.gz` | Read compressed file without extracting |

---

# 🔍 Text Processing

### Cut

Extract columns from TSV/CSV files.

```bash
cut -f3 sample.tsv
```

Extract first four columns

```bash
cut -f1-4 sample.tsv
```

Specify delimiter

```bash
cut -d "," -f2 sample.csv
```

---

### Paste

Merge files column-wise.

```bash
paste file1.txt file2.txt
```

---

### Grep

Search text.

```bash
grep "gene" file.txt
```

Ignore case

```bash
grep -i "gene" file.txt
```

---

### Sort

```bash
sort file.txt
sort -n file.txt
sort -r file.txt
```

---

### Unique

```bash
uniq file.txt
uniq -c file.txt
```

---

# ⚙ Background Jobs

Run a command in the background

```bash
nohup command &
```

Example

```bash
nohup python script.py &
```

View running jobs

```bash
jobs
```

Terminate a process

```bash
kill PID
```

---

# 📝 Lab Practice Questions

### Count lines in three files

```bash
wc -l file1 file2 file3
```

### Print first three lines

```bash
head -3 file.txt
```

### Merge two files

```bash
paste a.txt a.tsv
```

### Print third column

```bash
cut -f3 sample.tsv
```

---

# 📊 R Programming

## Working Directory

```R
getwd()
setwd("/path/to/folder")
```

---

## Reading Data

CSV

```R
my_data <- read.csv("sample.csv")
```

TSV

```R
my_data <- read.table("sample.tsv",
                      sep="\t",
                      header=TRUE)
```

---

## Installing Packages

```R
install.packages("ggplot2")
library(ggplot2)
```

---

# 📁 Creating a Data Frame

```R
mock_data <- data.frame(
  Sample_ID = c("S1","S2","S3","S4","S5","S6"),
  Expression = c(12.4,45.1,10.8,55.3,14.2,NA),
  Age = c(23,23,43,24,24,29)
)
```

---

## Exploring Data

```R
head(mock_data)
head(mock_data,3)
str(mock_data)
summary(mock_data)
dim(mock_data)
colnames(mock_data)
```

---

## Selecting Data

```R
mock_data$Age
mock_data[, "Age"]
mock_data[, c(1,3)]
```

---

## Modifying Data

```R
mock_data$Age <- mock_data$Age + 1
```

---

## Saving Data

CSV

```R
write.csv(mock_data,
          "sample_metadata.csv",
          row.names=FALSE)
```

TSV

```R
write.table(mock_data,
            "sample_metadata.tsv",
            sep="\t",
            row.names=FALSE,
            quote=FALSE)
```

---

# 📈 Data Visualization

Scatter Plot

```R
plot(mock_data$Age,
     mock_data$Expression,
     col="blue",
     pch=19,
     xlab="Age",
     ylab="Expression")
```

Grouped Scatter Plot

```R
mock_data$Group <- as.factor(mock_data$Group)

plot(
  mock_data$Age,
  mock_data$Expression,
  col=mock_data$Group,
  pch=19,
  cex=1.5
)

legend(
  "topleft",
  legend=levels(mock_data$Group),
  col=1:length(levels(mock_data$Group)),
  pch=19
)
```

---

# 💡 Useful Linux Shortcuts

| Shortcut | Description |
|----------|-------------|
| `history` | Show command history |
| `Ctrl + R` | Search previous commands |
| `Tab` | Auto-complete commands |
| `!!` | Repeat previous command |
| `clear` | Clear terminal |

---

# 📌 Repository Structure

```text
NGS_Lab/
├── Lab_1/
├── Lab_2/
├── Lab_3/
├── Lab_4/
├── datasets/
├── scripts/
└── README.md
```

---

# 👨‍💻 Author

**Keshav Pande**

**M.Sc. Big Data Biology**

**Institute of Bioinformatics and Applied Biotechnology (IBAB)**

**Course:** Next Generation Sequencing (NGS) Laboratory
