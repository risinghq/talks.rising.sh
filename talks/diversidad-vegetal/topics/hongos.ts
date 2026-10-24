import agaricus from "../img/hongos/agaricus.jpg";
import agaricusRep from "../img/hongos/agaricus-rep.jpg";
import caloplaca from "../img/hongos/caloplaca.jpg";
import cookeina from "../img/hongos/cookeina.jpg";
import cookeinaRep from "../img/hongos/cookeina-rep.jpg";
import cora from "../img/hongos/cora.jpg";
import everniopsis from "../img/hongos/everniopsis.jpg";
import ganoderma from "../img/hongos/ganoderma.jpg";
import ganodermaRep from "../img/hongos/ganoderma-rep.jpg";
import leptogium from "../img/hongos/leptogium.jpg";
import parmelia from "../img/hongos/parmelia.jpg";
import penicillium from "../img/hongos/penicillium.jpg";
import penicilliumRep from "../img/hongos/penicillium-rep.jpg";
import ramalina from "../img/hongos/ramalina.jpg";
import rhizopus from "../img/hongos/rhizopus.jpg";
import rhizopusRep from "../img/hongos/rhizopus-rep.jpg";
import saccharomyces from "../img/hongos/saccharomyces.jpg";
import saccharomycesRep from "../img/hongos/saccharomyces-rep.jpg";
import type { Band, Group, Topic } from "./types";

const bands: Band[] = [
  { name: "Mucoromycota", sub: "Zygomycota", span: 1 },
  { name: "Ascomycota", span: 3 },
  { name: "Basidiomycota", span: 2 },
];

const groups = (rep: boolean): Group[] => [
  { name: "Rhizopus", example: "moho negro del pan", img: rep ? rhizopusRep : rhizopus },
  { name: "Saccharomyces", example: "levadura", img: rep ? saccharomycesRep : saccharomyces },
  { name: "Penicillium", example: "y Aspergillus", img: rep ? penicilliumRep : penicillium },
  { name: "Cookeina", example: "hongo copa", img: rep ? cookeinaRep : cookeina },
  { name: "Agaricus", example: "champiñón", img: rep ? agaricusRep : agaricus },
  { name: "Ganoderma", example: "hongo repisa", img: rep ? ganodermaRep : ganoderma },
];

export const hongos: Topic = {
  slug: "hongos",
  name: "Fungi",
  clase: "Clase 5",
  summary: "Mucoromycota, Ascomycota, Basidiomycota y líquenes.",
  tables: [
    {
      id: "vegetativos",
      title: "Aspectos vegetativos",
      bands,
      cols: groups(false),
      rows: [
        {
          label: "Nutrición y pared",
          cells: [["**Heterótrofos** por **absorción**: saprófitos, parásitos o simbiontes. Pared celular de **quitina**. Reserva: **glucógeno**.", 6]],
        },
        {
          label: "Talo",
          cells: [
            ["**Micelio** de hifas **cenocíticas**: sin tabiques, multinucleadas.", 1],
            ["**Unicelular**: células ovoides, sin micelio verdadero.", 1],
            ["**Micelio** de hifas **tabicadas**, con septos de poro simple.", 2],
            ["**Micelio** de hifas **tabicadas**, con **dolíporo** y **fíbulas**.", 2],
          ],
        },
        {
          label: "Estructuras somáticas",
          cells: [
            ["**Estolones** y **rizoides** que fijan al sustrato.", 1],
            ["Célula con **cicatrices** de gemación.", 1],
            ["Hifas aéreas que forman **conidióforos**.", 1],
            ["Hifas entretejidas forman **plecténquima** (falso tejido) en el cuerpo fructífero.", 3],
          ],
        },
        {
          label: "Cuerpo fructífero",
          cells: [
            ["**Ausente**.", 3],
            ["**Apotecio** en forma de **copa**, rojo.", 1],
            ["**Basidiocarpo** carnoso: **píleo**, **láminas**, **estípite** y **anillo**; sin volva.", 1],
            ["**Basidiocarpo** **leñoso**, en repisa, con **poros**.", 1],
          ],
        },
        {
          label: "Hábitat",
          cells: [
            ["Pan, frutas y restos vegetales.", 1],
            ["Azúcares: fruta, mosto, masa de pan.", 1],
            ["Frutas, granos y alimentos guardados.", 1],
            ["Ramas caídas en bosque húmedo.", 1],
            ["Suelo con materia orgánica; cultivado.", 1],
            ["Troncos vivos o muertos.", 1],
          ],
        },
      ],
      notes: "Todos son heterótrofos por absorción con pared de quitina. Las hifas cenocíticas separan a Rhizopus; las fíbulas y el dolíporo, a los basidiomicetos. Saccharomyces es unicelular.",
    },
    {
      id: "reproductivos",
      title: "Aspectos reproductivos",
      bands,
      cols: groups(true),
      rows: [
        {
          label: "Reproducción asexual",
          cells: [
            ["**Esporangiosporas** en un **esporangio** con **columela**, sobre el esporangióforo.", 1],
            ["**Gemación**: la yema crece y se separa.", 1],
            ["**Conidios** en cadena sobre el **conidióforo**: en **pincel** (Penicillium) o sobre una **vesícula** (Aspergillus).", 1],
            ["**Fragmentación** del micelio. Las esporas sexuales son la vía principal.", 3],
          ],
        },
        {
          label: "Proceso sexual",
          cells: [
            ["**Gametangiogamia**: dos gametangios se fusionan.", 1],
            ["**Conjugación** de dos células haploides.", 1],
            ["**Ascogonio** y **anteridio** forman hifas ascógenas.", 2],
            ["**Somatogamia**: dos hifas se fusionan y forman un micelio **dicariótico**.", 2],
          ],
        },
        {
          label: "Estructura sexual",
          cells: [
            ["**Cigosporangio** de pared gruesa y oscura.", 1],
            ["**Asca libre**, sin ascocarpo.", 1],
            ["**Cleistotecio** cerrado.", 1],
            ["**Apotecio** abierto, himenio en la cara superior.", 1],
            ["**Himenio** en las **láminas**: basidios, basidiolos y cistidios.", 1],
            ["**Himenio** que tapiza los **tubos**.", 1],
          ],
        },
        {
          label: "Espora sexual",
          cells: [
            ["**Cigospora**.", 1],
            ["**4 ascosporas** endógenas en el asca.", 1],
            ["**8 ascosporas** endógenas en cada asca.", 2],
            ["**4 basidiosporas** exógenas sobre esterigmas del **basidio**.", 2],
          ],
        },
        {
          label: "Fase dominante",
          cells: [
            ["**Haploide** (n). El cigoto es la única fase diploide.", 1],
            ["Haploide o **diploide**: ambas se dividen por gemación.", 1],
            ["**Haploide** (n). Fase **dicariótica** breve: solo las hifas ascógenas.", 2],
            ["**Dicariótica** (n+n), de larga duración.", 2],
          ],
        },
      ],
      notes: "Espora sexual: cigospora en Mucoromycota, ascosporas endógenas en el asca en Ascomycota, basidiosporas exógenas en el basidio en Basidiomycota. La fase dicariótica es larga solo en Basidiomycota.",
    },
    {
      id: "liquenes",
      title: "Líquenes",
      tone: "liquen",
      bands: [
        { name: "Ascolíquenes", sub: "Ascomycota liquenizados", span: 5 },
        { name: "Basidiolíquen", span: 1 },
      ],
      cols: [
        { name: "Gelatinoso", example: "Leptogium", img: leptogium },
        { name: "Crustáceo", example: "Caloplaca, Graphis", img: caloplaca },
        { name: "Folioso", example: "Parmelia, Sticta", img: parmelia },
        { name: "Fruticuloso", example: "Ramalina, Usnea", img: ramalina },
        { name: "Subfruticuloso", example: "Everniopsis", img: everniopsis },
        { name: "Cora", example: "Cora glabrata", img: cora },
      ],
      rows: [
        {
          label: "Micobionte",
          cells: [
            ["**Ascomycota**, sobre todo Lecanoromycetes.", 5],
            ["**Basidiomycota** (Agaricomycetes).", 1],
          ],
        },
        {
          label: "Fotobionte",
          cells: [
            ["**Cianobacteria** (Nostoc).", 1],
            ["**Alga verde** (Chlorophyta).", 1],
            ["**Alga verde**. Sticta: alga verde o cianobacteria.", 1],
            ["**Alga verde** (Chlorophyta).", 2],
            ["**Cianobacteria**.", 1],
          ],
        },
        {
          label: "Talo",
          cells: [
            ["**Homómero**: fotobionte repartido en un talo gelatinoso.", 1],
            ["**Heterómero**, sin corteza inferior.", 1],
            ["**Heterómero**: córtex superior, capa algal, médula y córtex inferior.", 1],
            ["**Heterómero** radial. Usnea: **cordón central**.", 1],
            ["**Heterómero**, dorsiventral.", 1],
            ["**Heterómero**.", 1],
          ],
        },
        {
          label: "Forma",
          cells: [
            ["**Gelatinoso**, oscuro; se hincha al mojarse.", 1],
            ["Costra **adherida**, a menudo anaranjada, sobre **rocas**.", 1],
            ["Lóbulos planos; cara superior gris azulada, inferior **negra**.", 1],
            ["Ramas **aplanadas** (Ramalina) o **cilíndricas** con espínulas (Usnea).", 1],
            ["Parece fruticuloso, pero **dorsiventral**: caras distintas.", 1],
            ["**Folioso**, lobulado; gris, verdoso o blanquecino.", 1],
          ],
        },
        {
          label: "Fijación",
          cells: [
            ["Por **pelos** de la cara inferior.", 1],
            ["Toda la **cara inferior** adherida.", 1],
            ["**Rizinas**. Sticta: **cifelas** en la cara inferior.", 1],
            ["**Disco** basal de fijación.", 1],
            ["**Sin** una zona única de fijación.", 1],
            ["Sobre suelo, rocas o musgos.", 1],
          ],
        },
        {
          label: "Reproducción asexual",
          cells: [
            ["**Fragmentación**; algunas especies con **isidios**.", 1],
            ["**Fragmentación**.", 1],
            ["**Soredios** en **soralios** e **isidios**.", 1],
            ["**Soredios** en soralios; algunas Usnea con isidios.", 1],
            ["**Fragmentación**.", 2],
          ],
        },
        {
          label: "Reproducción sexual",
          cells: [
            ["**Apotecios**.", 1],
            ["**Apotecios**. Graphis: **lirelas** alargadas.", 1],
            ["**Apotecios** lecanorinos con ascosporas.", 3],
            ["**Basidios** en el **himenio** de la cara ventral.", 1],
          ],
        },
      ],
      notes: "El liquen es una simbiosis entre un micobionte y un fotobionte. El biotipo (gelatinoso, crustáceo, folioso, fruticuloso) depende del talo. Soredios e isidios llevan a los dos simbiontes juntos.",
      foot: "Solo el micobionte se reproduce sexualmente",
    },
  ],
};
