- [Go Template](https://godoc.org/text/template)
- Dry run values of a template
```BASH
helm template RELEASE .<Chart path> # Will render the template along with the default values
```
- **Template Macros**: Used for reusing code in the helm templates and is written in `_helpers.tpl`