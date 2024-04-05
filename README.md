# pages_to_odt
BASH script to convert (XML-based) Apple .pages files to .odt (OpenDocument) files.
## Disclaimer
I wrote this with the help of OpenAI's ChatGPT, but I plan to make certain adjustments to it myself and am willing to accept pull requests from others to make the script even more human-generated.
## Dependencies
* `find`
* `libreoffice` (specifically command-line tools)
* `zip`
## Usage
This script searches a directory (and sub-directories if -R flag is added) for any Apple Pages documents (ending in .pages).
If the .pages document is a ZIP file (most are), the script then passes it to `libreoffice` for conversion.
If the .pages document is a directory, the contents of the directory are first zipped and then sent to `libreoffice` for conversion.
The converted files should be automatically moved to the directory of the original file.
