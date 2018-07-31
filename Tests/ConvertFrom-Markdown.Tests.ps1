Describe "Unit Tests for MarkdownEx" -Tag "Build" {
    Context "ConvertFrom-Markdown Unit Tests" {

        it "Converts headers" {
            $("# H1" | ConvertFrom-Markdown) | Should -match '<h1 id="h1">H1</h1>\n'
        }
        it "Converts links" {
            $("[text](url)" | ConvertFrom-Markdown) | Should -match '<a href="url">text</a>'
        }
        it "Converts lists" {
            $("* item`n* item" | ConvertFrom-Markdown) | Should -match '<ul>\n<li>item</li>\n<li>item</li>\n</ul>\n'
        }
        it "Converts tables" {
            $("| Header 1 | Header 2|`n|---|---|`n| Item 1 | Item 2 |" | ConvertFrom-Markdown) | Should -match '<table>\n<thead>\n<tr>\n<th>Header 1</th>\n<th>Header 2</th>\n</tr>\n</thead>\n<tbody>\n<tr>\n<td>Item 1</td>\n<td>Item 2</td>\n</tr>\n</tbody>\n</table>\n'
        }
        it "I think we're good" {
            $true | Should -be $true
        }
    }
}