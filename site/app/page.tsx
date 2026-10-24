import Link from "next/link";

const talks = [
  { href: "/diversidad-vegetal/", tag: "UNMSM", name: "Diversidad Vegetal", summary: "Cuadros comparativos de hongos y líquenes, briofitos y helechos." },
  { href: "https://github.com/totallynotdavid/slides/tree/master/talks/deploy-django", tag: "Typst", name: "Deploy en la nube", summary: "Django en AWS con Docker, Terraform y nginx." },
];

export default function Home() {
  return (
    <main className="index">
      <p className="eyebrow">
        <i />
        Slides
      </p>
      <h1>Presentaciones</h1>
      <ul>
        {talks.map((t) => (
          <li key={t.href}>
            <Link href={t.href}>
              <small>{t.tag}</small>
              <b>{t.name}</b>
              <span>{t.summary}</span>
            </Link>
          </li>
        ))}
      </ul>
    </main>
  );
}
