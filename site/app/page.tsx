const talks = [
  { href: "/diversidad-vegetal/", tag: "UNMSM", name: "Diversidad Vegetal", summary: "Cuadros comparativos de hongos y líquenes, briofitos y helechos." },
  { href: "/deploy-django/", tag: "Workshop", name: "Deploy en la nube", summary: "Django en AWS con Docker, Terraform y nginx." },
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
            <a href={t.href}>
              <small>{t.tag}</small>
              <b>{t.name}</b>
              <span>{t.summary}</span>
            </a>
          </li>
        ))}
      </ul>
    </main>
  );
}
