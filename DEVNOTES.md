
## GFM

Nowadays becoming a widely adapted standard it is our goal to get lists _right_ (in the sense of GFM).
For that purpose, a condensed, and maybe understandable definition:

### List items, as defined [here](https://github.github.com/gfm/#list-items)  

#### Width of a list marker

Indent to be removed for the content is Width + N following spaces with N in 1..4



### Lists, as defined [here](https://github.github.com/gfm/#lists)  

#### Loose or tight

A list is _loose_ iff any of the following conditions occur

- two of its list items are separated by blank lines
- any of its list items contain two block elements with blank lines separating them

Effect:

- Loose list -> `<p><li>...</li></p>`
- Tight list -> `<li>...</li>`

> It seems we can define the looseness of a list by a loose attribute on its items
> to be set during parsing of the list which will pop up via `Enum.any?(&(&1.loose?))`=

### Implications of Paragraph Continuation Text as defined  [here](https://github.github.com/gfm/#paragraph-continuation-text) 

- content must not begin with a blank line
- ols need to start with 1


### Implication of [Thematic Breaks](https://github.github.com/gfm/#thematic-breaks)  

### Creating docs

This is tricky as we have a circular dependency problem between `Earmark` and `ExDoc`

However, helped by José Valim it can be done with a rather simple workaround for the doc task
in [mix.exs](mix.exs)  


###### How block elements are rendered:

     a line
     <div>headline</div>

as

      <p>a line</p>
      <div>headline</div>

###### List of Block Elements

* address
* article
* aside
* blocksuote
* canvas
* dd
* div
* dl
* fieldset
* figcaption
* h1
* h2
* h3
* h4
* h5
* h6
* header
* hgroup
* li
* main
* nav
* noscript
* ol
* output
* p
* pre
* section
* table
* tfoot
* ul
* video
