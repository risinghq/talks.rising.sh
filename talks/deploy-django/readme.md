# Deploy en la nube

A workshop on deploying Django to AWS with Docker, Terraform and nginx.

The slides are [`slides.mdx`](slides.mdx). Each top-level element is one slide,
built from the components in
[`packages/deck/mdx.tsx`](../../packages/deck/mdx.tsx), and each `<Section>`
becomes an entry in the agenda. Images live in [`img/`](img) and are imported at
the top of the file. [`theme.css`](theme.css) sets the palette.

[`proyecto1/`](proyecto1) is the Django project the workshop deploys, with its
Dockerfile and Terraform. `mise //talks/deploy-django/proyecto1:image` builds
its image.
