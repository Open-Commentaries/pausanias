import csv

from pathlib import Path

with open(Path("out/tlg0525.tlg001.perseus-grc2.entities.csv"), newline="") as f:
    reader = csv.DictReader(f)

    for row in reader:
        entity_link = row.get('entity_link', '')
        if entity_link != '':
            print(row)
