#!/bin/bash

command=$1

case $command in

  summary)
    file=$2

    rows=$(($(wc -l < "$file") - 1))
    cols=$(head -1 "$file" | awk -F',' '{print NF}')

    echo "Rows: $rows"
    echo "Columns: $cols"
    ;;
  filter)
    condition=$2
    file=$3

    col=$(echo "$condition" | cut -d'=' -f1)
    val=$(echo "$condition" | cut -d'=' -f2)

    col_index=$(head -1 "$file" | tr ',' '\n' | nl | grep -w "$col" | awk '{print $1}')

    if [ -z "$col_index" ]; then
      echo "Column not found!"
      exit 1
    fi
    head -1 "$file"

    awk -F',' -v col="$col_index" -v val="$val" '
    NR>1 && $col == val
    ' "$file"
    ;;

  avg)
    arg=$2
    file=$3

    col_index=$(head -1 "$file" | tr ',' '\n' | nl | grep -w "$arg" | awk '{print $1}')

    if [ -z "$col_index" ]; then
      echo "Column not found!"
      exit 1
    fi

    awk -F',' -v col="$col_index" '
    NR>1 {sum += $col; count++}
    END {
      if (count > 0)
        print "Average:", sum/count
      else
        print "No data"
    }
    ' "$file"
    ;;
max)
    arg=$2
    file=$3
    col_index=$(head -1 "$file" | tr ',' '\n' | nl | grep -w "$arg" | awk '{print $1}')
    if [ -z "$col_index" ]; then
      echo "Column not found!"
      exit 1
    fi
    awk -F',' -v col="$col_index" 'NR>1 {if(max==""){max=$col}; if($col>max){max=$col}} END {print "Max:", max}' "$file"
    ;;

  min)
    arg=$2
    file=$3
    col_index=$(head -1 "$file" | tr ',' '\n' | nl | grep -w "$arg" | awk '{print $1}')
    if [ -z "$col_index" ]; then
      echo "Column not found!"
      exit 1
    fi
    awk -F',' -v col="$col_index" 'NR>1 {if(min==""){min=$col}; if($col<min){min=$col}} END {print "Min:", min}' "$file"
    ;;

  count)
    condition=$2
    file=$3
    col=$(echo "$condition" | cut -d'=' -f1)
    val=$(echo "$condition" | cut -d'=' -f2)
    col_index=$(head -1 "$file" | tr ',' '\n' | nl | grep -w "$col" | awk '{print $1}')
    if [ -z "$col_index" ]; then
      echo "Column not found!"
      exit 1
    fi
    awk -F',' -v col="$col_index" -v val="$val" 'NR>1 && $col==val {count++} END {print count+0}' "$file"
    ;;

  *)
    echo "Usage:"
    echo './datacli.sh summary <file>'
    echo './datacli.sh avg <column> <file>'
    ;;
esac