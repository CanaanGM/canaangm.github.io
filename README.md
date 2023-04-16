# taking chirpy for a spin

> this is my blog and website for the foreseeable future, so wlecome!

---
### easily startdeveloping
1. clone it
2. open it with VSCode, then open it in Dev Container
    - if there's no `.devcontainer` file create one by clicking on the lower most left of VSC window or `ctr + shift + p` -> dev container
3. Generate a *post* **or** */* **and** *start* the dev server
    - install deps first: `bundle`
    - gen a post: `bundle exec jekyll post <post name>`, u'd need [jekyll compose](https://github.com/jekyll/jekyll-compose)
    - start the server: `bundle exec jekyll s --livereload`

---
### post syntax

you need to add front matter ; the :
```md
---
stuff
---
or
+++
stuff
+++
```
at the top of the file.

in them you can add:
- **title**  : the name of the file
- **layout** : in what layout the file will be dispalyed in
- **date** : the date of the post
- **math** : math
- **image** : cover image, ***yaml*** style without `-`
- **categories** : a list of string `[ cat_papa, cat_child ]` the first is the parent then a child
- **tags** :  a list of tags `[tag1, tag2, ... , tagN]` however many u want


---

> made with jekull and [chripy](https://github.com/cotes2020/jekyll-theme-chirpy) by [cotes2020](https://github.com/cotes2020)
