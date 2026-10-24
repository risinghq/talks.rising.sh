import equisetum from "../img/helechos/equisetum.jpg";
import equisetumRep from "../img/helechos/equisetum-rep.jpg";
import lyco from "../img/helechos/lyco.jpg";
import lycoRep from "../img/helechos/lyco-rep.jpg";
import marattia from "../img/helechos/marattia.jpg";
import marattiaRep from "../img/helechos/marattia-rep.jpg";
import ophioglossum from "../img/helechos/ophioglossum.jpg";
import ophioglossumRep from "../img/helechos/ophioglossum-rep.jpg";
import polypodium from "../img/helechos/polypodium.jpg";
import polypodiumRep from "../img/helechos/polypodium-rep.jpg";
import type { Band, Group, Topic } from "./types";

const bands: Band[] = [
  { name: "Licófitas", sub: "Lycopodiopsida", span: 1 },
  { name: "Helechos", sub: "Polypodiopsida", span: 4 },
];

const groups = (rep: boolean): Group[] => [
  { name: "Lycopodiidae", example: "Lycopodium, Selaginella, Isoetes", img: rep ? lycoRep : lyco },
  { name: "Equisetidae", example: "Equisetum", img: rep ? equisetumRep : equisetum },
  { name: "Ophioglossidae", example: "Ophioglossum", img: rep ? ophioglossumRep : ophioglossum },
  { name: "Marattiidae", example: "Marattia", img: rep ? marattiaRep : marattia },
  { name: "Polypodiidae", example: "Polypodium, Adiantum, Nephrolepis, Azolla, Cyathea", img: rep ? polypodiumRep : polypodium },
];

export const helechos: Topic = {
  slug: "helechos",
  name: "Helechos",
  clase: "Clase 7",
  summary: "Licófitas y los cuatro grupos de helechos.",
  tables: [
    {
      id: "vegetativos",
      title: "Aspectos vegetativos",
      bands,
      cols: groups(false),
      rows: [
        {
          label: "Fase dominante",
          cells: [["**Esporofito** (2n) independiente, con **raíz**, **tallo** y **hojas** verdaderas y **tejido vascular**. El gametofito (**prótalo**) vive libre, sin tejido conductor.", 5]],
        },
        {
          label: "Tallo",
          cells: [
            ["Ramificación **dicotómica**. Selaginella: **rizóforo**. Isoetes: cormo corto.", 1],
            ["**Nudos** y **entrenudos**, con estrías y epidermis **silicificada**. Ramas **verticiladas**.", 1],
            ["**Rizoma** corto y carnoso.", 1],
            ["**Rizoma** robusto y carnoso, con **escamas**.", 1],
            ["**Rizoma**. Cyathea: tallo **arborescente**.", 1],
          ],
        },
        {
          label: "Hojas",
          cells: [
            ["**Micrófilos**, con una sola vena. Selaginella: en 4 hileras, con **lígula**.", 1],
            ["**Micrófilos** escamosos **verticilados**, soldados en una **ocrea**. Fotosintetiza el **tallo**.", 1],
            ["Una hoja por año: **segmento estéril** y **espiga fértil**. Vernación **no circinada**.", 1],
            ["**Megáfilos** grandes, con **estípulas** en la base. Vernación **circinada**.", 1],
            ["**Frondes** (megáfilos) pinnadas. Vernación **circinada** (báculo).", 1],
          ],
        },
        {
          label: "Raíces",
          cells: [
            ["Adventicias, ramificación **dicotómica**.", 1],
            ["Adventicias, en los **nudos** del rizoma.", 1],
            ["Carnosas, sin pelos radicales; **micorrízicas**.", 1],
            ["Gruesas y carnosas.", 1],
            ["**Adventicias**, no dicotómicas, a lo largo del rizoma.", 1],
          ],
        },
        {
          label: "Gametofito",
          cells: [
            ["Lycopodium: **subterráneo**, sin clorofila, longevo. Selaginella e Isoetes: **endospórico**.", 1],
            ["**Verde**, lobulado, sobre el suelo.", 1],
            ["**Subterráneo**, sin clorofila, **micorrízico**.", 1],
            ["**Verde**, cordiforme, grande y longevo.", 1],
            ["**Prótalo** verde **cordiforme**, de vida corta.", 1],
          ],
        },
      ],
      notes: "Las licófitas tienen micrófilos; los helechos, megáfilos (Equisetum los reduce a escamas). La vernación circinada aparece en Marattiidae y Polypodiidae. El prótalo es libre y sin tejido conductor.",
    },
    {
      id: "reproductivos",
      title: "Aspectos reproductivos",
      bands,
      cols: groups(true),
      rows: [
        {
          label: "Esporangio",
          cells: [
            ["**Eusporangio**: pared de varias capas, nace de **varias células**, muchas esporas.", 4],
            ["**Leptosporangio**: pared de **una capa**, nace de **una célula**, con pedicelo y **anillo**.", 1],
          ],
        },
        {
          label: "Ubicación",
          cells: [
            ["En la base de los **esporofilos**, agrupados en **estróbilos**.", 1],
            ["Bajo **esporangióforos** peltados, en un **estróbilo** apical.", 1],
            ["En dos hileras dentro de la **espiga fértil**.", 1],
            ["Fusionados en **sinangios**, en el envés; sin indusio.", 1],
            ["En **soros** en el envés, con o sin **indusio**. Adiantum: **falso indusio**.", 1],
          ],
        },
        {
          label: "Esporas",
          cells: [
            ["Lycopodium: **homospórico**. Selaginella e Isoetes: **heterospóricos**.", 1],
            ["**Homospórico**; esporas con **eláteres**.", 1],
            ["**Homospórico**; esporas triletes.", 1],
            ["**Homospórico**; esporas monoletes.", 1],
            ["Casi todos **homospóricos**. Azolla: **heterospórica**.", 1],
          ],
        },
        {
          label: "Dehiscencia",
          cells: [
            ["Por una hendidura **transversal**.", 1],
            ["Por una hendidura **longitudinal**.", 1],
            ["Por una hendidura **transversal**.", 1],
            ["Incisión **bivalvada**, como una **almeja**, de apertura longitudinal.", 1],
            ["El **anillo** se seca, se contrae y rompe el **estomio**.", 1],
          ],
        },
        {
          label: "Fecundación",
          cells: [
            ["Anterozoides **biflagelados**. Isoetes: **multiflagelados**.", 1],
            ["Anterozoides **multiflagelados**.", 4],
          ],
        },
        {
          label: "Agua",
          cells: [["Los anterozoides **nadan** hasta el arquegonio: la fecundación **requiere agua**.", 5]],
        },
      ],
      notes: "El esporangio separa a Polypodiidae (leptosporangio con anillo) del resto (eusporangio). La heterosporia aparece en Selaginella, Isoetes y Azolla. Todos necesitan agua para la fecundación.",
    },
  ],
};
