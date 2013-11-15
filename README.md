# Coopy for Ruby

[![Build Status](http://jenkins.theodi.org/job/coopy-ruby-master/badge/icon)](http://jenkins.theodi.org/job/coopy-ruby-master/)
[![Dependency Status](https://gemnasium.com/theodi/coopy-ruby.png)](https://gemnasium.com/theodi/coopy-ruby)
[![Code Climate](https://codeclimate.com/github/theodi/coopy-ruby.png)](https://codeclimate.com/github/theodi/coopy-ruby)

A pure Ruby port of Paul Fitzpatrick's [coopyhx](http://paulfitz.github.io/coopyhx) library for tabular diffs.

Not all the coopyhx code is ported or tested. There will be bugs. However, basic two-file CSV diff appears to be working. See 'Usage' section below for details.

## Installation

Add this line to your application's Gemfile:

    gem 'coopy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install coopy

## Usage

You can diff Ruby's built-in CSV objects, like so:

```
old_table = Coopy::CsvTable.new(old_csv_object)
new_table = Coopy::CsvTable.new(new_csv_object)

alignment = Coopy.compare_tables(old_table,new_table).align
flags = Coopy::CompareFlags.new
highlighter = Coopy::TableDiff.new(alignment,flags)

diff_table = Coopy::SimpleTable.new(0,0)
highlighter.hilite diff_table
```

You can inspect `diff_table` to see the changes.

You can also generate an HTML view of this diff like this:

```
diff2html = Coopy::DiffRender.new
diff2html.render diff_table
html = diff2html.html
```

There is plenty more in the original coopyhx, but this is all that's known working at the moment.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
