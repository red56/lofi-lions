# Transforms

There are some utilities when you find that your already translated keys need manipulating (splitting, combining, find and replace)

## How to use the transforms

```ruby
project = Project.find_by_name("Some project")
```

### Rename

```ruby
project.master_texts.with_keys("some_prefix_c_01_header").each do |master_text|
  master_text.update!(key: "some_prefix_c_01_heading")
end
```

### split md into paragraphs

split some_prefix_c_01_md into separate paragraphs (to some_prefix_c_01_P0x)

```ruby
project.master_texts.with_keys("some_prefix_c_01_md").each do |master_text|
  master_text.md_to_paragraphs!(base_key: "some_prefix_c_01")
end
```

### Split a bunch of md in to heading (preceeded by ### etc) and text 

for each of some_prefix_c_0x_md split into some_prefix_c_0x_heading and some_prefix_c_0x_body_md

```ruby
project.master_texts.with_keys(/some_prefix_c_\d+_md/).each do |master_text|
  master_text.md_to_heading_and_text!
end
```

### Split into sections 

split out some_prefix_c_02_body -- into  some_prefix_c_02_0N_heading and  some_prefix_c_02_0N_para (alternate paragraphs)

```ruby
project.master_texts.with_keys("some_prefix_c_02_text").each do |master_text|
  master_text.split_to_sections(base_key: "some_prefix_c_02")
end
```

### Find and replace in both main (English) and translations

```ruby
project.find_and_replace(
  "DBA Megacorp" => "Megacorp Inc",
  "Captain Fun" => "Mr Serious",
)
```
### Find and replace for one language (across projects)

e.g. fix up french punctuation:

```ruby
  french = Language.find_by_name("French")
  nbsp = [160].pack('U*')
  french.project_languages.flat_map(&:localized_texts).each do |lt|
    transformed = lt.other.gsub(/[ #{nbsp}]?([:;!?»])[ #{nbsp}]?/, "#{nbsp}\\1 ")
    transformed = transformed.gsub(/[ #{nbsp}]?([«])[ #{nbsp}]?/, " \\1#{nbsp}").strip
    transformed = transformed.gsub(%r<(http|https|mailto)#{nbsp}: >, "\\1:") # fix improperly changed urls
    transformed = transformed.gsub(/»#{nbsp})/, "»)")
    transformed = transformed.gsub(/\(#{nbsp}«/, "(«")
    transformed = transformed.gsub(/’#{nbsp}«/, "’«")
    transformed.chop! if transformed.ends_with?(nbsp)
    lt.update(other: transformed) unless transformed == lt.other
  end; nil
  french.project_languages.each(&:recalculate_counts!); nil
```
