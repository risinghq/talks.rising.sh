// Each cell is [text, span]. **x** marks a key term. A span over several
// columns means the trait is shared by those groups.
export type Row = { label: string; cells: [string, number][] };
// img is a static image import; the site's bundler gives it a hashed URL.
export type Group = { name: string; example: string; img: { src: string } };
export type Band = { name: string; sub?: string; span: number };

export type Table = {
  id: string;
  title: string;
  bands: Band[];
  cols: Group[];
  rows: Row[];
  notes: string;
  foot?: string;
  // A palette from talks/diversidad-vegetal/theme.css that replaces the topic's palette on this slide.
  tone?: string;
};

export type Topic = { slug: string; name: string; clase: string; summary: string; tables: Table[] };
