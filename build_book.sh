#!/bin/bash

BOOK="book/Engineering_Design_Document.md"

rm -f "$BOOK"

echo "# Adaptive Fraud Intelligence Platform" >> "$BOOK"
echo "" >> "$BOOK"
echo "## Engineering Design Document" >> "$BOOK"
echo "" >> "$BOOK"
echo "**Version:** 0.2" >> "$BOOK"
echo "" >> "$BOOK"
echo "---" >> "$BOOK"

echo "# Table of Contents" >> "$BOOK"
echo "" >> "$BOOK"

echo "## Foundation" >> "$BOOK"
echo "1. Project Scope" >> "$BOOK"
echo "2. Documentation Guide" >> "$BOOK"
echo "3. Project Charter" >> "$BOOK"
echo "4. Project Overview" >> "$BOOK"
echo "" >> "$BOOK"

echo "## Data Engineering" >> "$BOOK"
echo "5. Dataset" >> "$BOOK"
echo "6. Exploratory Data Analysis" >> "$BOOK"
echo "7. Feature Engineering" >> "$BOOK"
echo "" >> "$BOOK"

echo "---" >> "$BOOK"

echo "# Chapter 1 - Project Scope" >> "$BOOK"
cat docs/00_Foundation/PROJECT_SCOPE.md >> "$BOOK"

echo "" >> "$BOOK"
echo "---" >> "$BOOK"

echo "# Chapter 2 - Documentation Guide" >> "$BOOK"
cat docs/00_Foundation/DOCUMENTATION_GUIDE.md >> "$BOOK"

echo "" >> "$BOOK"
echo "---" >> "$BOOK"

echo "# Chapter 3 - Project Charter" >> "$BOOK"
cat docs/00_Foundation/PROJECT_CHARTER.md >> "$BOOK"

echo "" >> "$BOOK"
echo "---" >> "$BOOK"

echo "# Chapter 4 - Project Overview" >> "$BOOK"
cat docs/00_Foundation/PROJECT_OVERVIEW.md >> "$BOOK"

echo "" >> "$BOOK"
echo "---" >> "$BOOK"

echo "# Chapter 5 - Dataset" >> "$BOOK"
cat docs/10_Data/DATASET.md >> "$BOOK"

echo "" >> "$BOOK"
echo "---" >> "$BOOK"

echo "# Chapter 6 - Exploratory Data Analysis" >> "$BOOK"
cat docs/10_Data/EDA.md >> "$BOOK"

echo "" >> "$BOOK"
echo "---" >> "$BOOK"

echo "# Chapter 7 - Feature Engineering" >> "$BOOK"
cat docs/10_Data/FEATURE_ENGINEERING.md >> "$BOOK"

echo ""
echo "Engineering Design Document Generated Successfully!"