import foliosa from "../img/briofitos/foliosa.jpg";
import foliosaRep from "../img/briofitos/foliosa-rep.jpg";
import musgo from "../img/briofitos/musgo.jpg";
import musgoRep from "../img/briofitos/musgo-rep.jpg";
import talosa from "../img/briofitos/talosa.jpg";
import talosaRep from "../img/briofitos/talosa-rep.jpg";
import type { Band, Group, Row, Topic } from "./types";

const bands: Band[] = [
  { name: "Hepáticas", sub: "Marchantiophyta", span: 2 },
  { name: "Musgos", sub: "Bryophyta", span: 1 },
];

const groups = (rep: boolean): Group[] => [
  { name: "Talosas", example: "Marchantia, Lunularia, Riccia", img: rep ? talosaRep : talosa },
  { name: "Foliosas", example: "Frullania, Plagiochila, Porella", img: rep ? foliosaRep : foliosa },
  { name: "Musgos", example: "Polytrichum, Funaria, Sphagnum", img: rep ? musgoRep : musgo },
];

const vegetativos: Row[] = [
  {
    label: "Fase dominante",
    cells: [["**Gametofito** (n), de vida libre y fotosintético. El **esporofito** (2n) es de corta duración y **depende** nutricionalmente de él.", 3]],
  },
  {
    label: "Protonema",
    cells: [
      ["**Reducido**, globoso o taloso. Origina **un solo** gametóforo.", 2],
      ["**Filamentoso** y ramificado (cloronema y caulonema). Origina **muchos** gametóforos.", 1],
    ],
  },
  {
    label: "Gametofito",
    cells: [
      ["**Talo** aplanado, **dorsiventral**, de ramificación **dicotómica**. Complejo, con **cámaras aeríferas** y **poros**.", 1],
      ["**Eje** con **filidios** en 2–3 hileras: 2 laterales y 1 ventral de **anfigastrios**. **Dorsiventral**.", 1],
      ["**Caulidio** con **filidios** en **espiral**. Simetría **radial**. Acrocárpicos o pleurocárpicos.", 1],
    ],
  },
  {
    label: "Filidios",
    cells: [
      ["**Ausentes**. Cara ventral con **escamas**.", 1],
      ["**Sin costa**, de una capa de células, a menudo **lobulados**.", 1],
      ["Con **costa** (nervio). **Lamelas** en Polytrichum; **clorocistos** y **leucocistos** en Sphagnum.", 1],
    ],
  },
  {
    label: "Rizoides",
    cells: [
      ["**Unicelulares**, lisos y **tuberculados**.", 1],
      ["**Unicelulares** y lisos.", 1],
      ["**Pluricelulares**, ramificados, con tabiques **oblicuos**.", 1],
    ],
  },
  {
    label: "Células",
    cells: [
      ["Con **oleocuerpos**, exclusivos de las hepáticas. **Trígonos** en Frullania.", 2],
      ["**Sin** oleocuerpos.", 1],
    ],
  },
  {
    label: "Tejido conductor",
    cells: [
      ["Generalmente **ausente**.", 2],
      ["Cordón central con **hidroides** (agua) y **leptoides** (nutrientes) en Polytrichum.", 1],
    ],
  },
];

const reproductivos: Row[] = [
  {
    label: "Reproducción asexual",
    cells: [
      ["**Propágulos** en **conceptáculos** en forma de copa; fragmentación.", 1],
      ["**Fragmentación** y propágulos en el margen de los filidios.", 1],
      ["**Fragmentación**, **yemas** y protonema secundario.", 1],
    ],
  },
  {
    label: "Gametangios",
    cells: [
      ["En **anteridióforos** y **arquegonióforos** pedunculados (Marchantia) o hundidos en el talo.", 1],
      ["Arquegonios en el **ápice** del eje, rodeados por el **perianto**.", 1],
      ["En el **ápice**, entre **paráfisis**, rodeados por **perigonio** (♂) y **periquecio** (♀).", 1],
    ],
  },
  {
    label: "Fecundación",
    cells: [["**Anterozoides biflagelados** que nadan hasta la ovocélula: requiere **agua**.", 3]],
  },
  {
    label: "Seta",
    cells: [
      ["**Hialina** y frágil. Se alarga **después** de madurar la cápsula. Muy corta en Marchantia.", 2],
      ["**Rígida**, verde al inicio. Se alarga **antes** de madurar la cápsula. Sphagnum: **pseudopodio**.", 1],
    ],
  },
  {
    label: "Caliptra",
    cells: [
      ["Se rompe y queda en la **base** de la seta.", 2],
      ["Se rompe y cubre la cápsula como **capuchón**.", 1],
    ],
  },
  {
    label: "Cápsula",
    cells: [
      ["**Sin** columela, estomas, opérculo ni peristoma. Se abre de forma **irregular**.", 1],
      ["**Sin** columela, estomas, opérculo ni peristoma. Se abre en **4 valvas**.", 1],
      ["Con **columela**, **estomas**, **opérculo** y **peristoma** (dientes).", 1],
    ],
  },
  {
    label: "Dispersión",
    cells: [
      ["**Eláteres** higroscópicos entre las esporas.", 2],
      ["**Peristoma**: sus dientes abren y cierran con la humedad. Sphagnum: opérculo **explosivo**.", 1],
    ],
  },
  {
    label: "Esporofito",
    cells: [
      ["**Efímero**: se marchita al liberar las esporas.", 2],
      ["Más **persistente**.", 1],
    ],
  },
];

export const briofitos: Topic = {
  slug: "briofitos",
  name: "Briofitos",
  clase: "Clase 6",
  summary: "Hepáticas talosas, hepáticas foliosas y musgos.",
  tables: [
    {
      id: "vegetativos",
      title: "Aspectos vegetativos",
      bands,
      cols: groups(false),
      rows: vegetativos,
      notes: "Gametofito: talo, eje foliado dorsiventral o caulidio radial. Rasgos clave: oleocuerpos y rizoides unicelulares en hepáticas; costa, rizoides pluricelulares e hidroides en musgos.",
    },
    {
      id: "reproductivos",
      title: "Aspectos reproductivos",
      bands,
      cols: groups(true),
      rows: reproductivos,
      notes: "Esporofito: en hepáticas la seta crece después de madurar la cápsula y hay eláteres; en musgos la seta crece antes, la cápsula tiene opérculo y peristoma.",
    },
  ],
};
