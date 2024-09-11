from MyCapytain.common.constants import Mimetypes
from MyCapytain.resources.texts.local.capitains.cts import CapitainsCtsText
from lxml import etree


class Token:
    """
    The weird thing about the internal implementation of tokens used
    in Kodon is that their `text` fields maintain their 
    trailing punctuation so that the frontend can stitch things together
    easily.

    For the NLP tasks, it's probably best to let the model handle
    segmentation and tokenization.
    """
    
    offset: int
    text: str
    urn: str
    urn_index: int
    xml_id: str

    def __init__(self, offset, text, urn, urn_index, xml_id):
        self.offset = offset
        self.text = text
        self.urn = urn
        self.urn_index = urn_index
        self.xml_id = xml_id


class TextBlock:
    offset: int
    urn: str
    location: list[str]
    text: str
    subtype: str
    tokens: list[Token]

    def __init__(
        self, offset: int, urn: str, location: list[str], text: str, subtype: str
    ):
        self.offset = offset
        self.urn = urn
        self.location = location
        self.text = text
        self.subtype = subtype
        self.tokens = self.tokenize()

    def tokenize(self):
        return []


class PausaniasParser:
    def __init__(self):
        with open("tei/tlg0525.tlg001.perseus-grc2.xml") as f:
            self.text = CapitainsCtsText(
                urn="urn:cts:greekLit:tlg0525.tlg001.perseus-grc2", resource=f
            )

    def export(self):
        urns = []
        raw_xmls = []
        unannotated_strings = []

        for ref in self.text.getReffs(level=len(self.text.citation)):
            urn = f"{self.text.urn}:{ref}"
            node = self.text.getTextualNode(ref)
            raw_xml = node.export(Mimetypes.XML.TEI)
            tree = node.export(Mimetypes.PYTHON.ETREE)
            s = etree.tostring(tree, encoding="unicode", method="text")  # type: ignore

            urns.append(urn)
            raw_xmls.append(raw_xml)
            unannotated_strings.append(s.strip())

if __name__ == '__main__':
    PausaniasParser().export()
