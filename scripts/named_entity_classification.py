from flair.models import SequenceTagger
from flair.splitter import SegtokSentenceSplitter
from pathlib import Path

import csv
import json


class Tagger:
    def __init__(self, filename) -> None:
        self.filename = Path(filename)
        self.tagger = SequenceTagger.load("UGARIT/flair_grc_bert_ner")
        self.splitter = SegtokSentenceSplitter()

    def process_entities(self):
        fieldnames = [
            "text_container_index",
            "entity_urn",
            "entity_text",
            "entity_type",
            "confidence",
            "entity_link",
        ]

        with open(
            "./out/editions.tlg0525.tlg001.perseus-grc2.entities.csv", "w+"
        ) as csv_out:
            output = csv.DictWriter(csv_out, fieldnames=fieldnames)

            output.writeheader()
            with open(self.filename, "r", -1, "utf-8") as f:
                for l in f.readlines():
                    section = json.loads(l)

                    if (
                        section["type"] == "text_container"
                        and section["text"].strip() != ""
                    ):
                        entities = self.tag_section(section["text"])

                        for entity in entities:
                            entity = entity.to_dict()
                            pre_text = section["text"][0 : entity["start_pos"]]
                            urn_index = pre_text.count(entity["text"]) + 1
                            entity_urn = (
                                f"{section['urn']}@{entity['text']}[{urn_index}]"
                            )
                            entity_type = entity["labels"][0]["value"]
                            confidence = entity["labels"][0]["confidence"]

                            output.writerow(
                                dict(
                                    text_container_index=section["index"],
                                    entity_urn=entity_urn,
                                    entity_text=entity["text"],
                                    entity_type=entity_type,
                                    confidence=confidence,
                                    entity_link="",
                                )
                            )

                        print(f"Wrote section {section['index']}")

    def tag_section(self, text):
        if text.strip() == "":
            return []

        sentences = self.splitter.split(text)

        entities = []

        for sentence in sentences:
            self.tagger.predict(sentence)

            entities += sentence.get_spans("ner")

        return entities


if __name__ == "__main__":
    f = "./out/editions/tlg0525.tlg001.perseus-grc2.jsonl"

    tagger = Tagger(f)
    tagger.process_entities()
