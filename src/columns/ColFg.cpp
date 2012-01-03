////////////////////////////////////////////////////////////////////////////////
// taskwarrior - a command line task list manager.
//
// Copyright 2006-2012, Paul Beckingham, Federico Hernandez.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// http://www.opensource.org/licenses/mit-license.php
//
////////////////////////////////////////////////////////////////////////////////


#define L10N                                           // Localization complete.

#include <Context.h>
#include <ColFg.h>
#include <text.h>
#include <i18n.h>

extern Context context;

////////////////////////////////////////////////////////////////////////////////
ColumnFg::ColumnFg ()
{
  _name  = "fg";
  _type  = "string";
  _style = "default";
  _label = STRING_COLUMN_LABEL_FG;

  _styles.push_back ("default");

  _examples.push_back ("red");
}

////////////////////////////////////////////////////////////////////////////////
ColumnFg::~ColumnFg ()
{
}

////////////////////////////////////////////////////////////////////////////////
bool ColumnFg::validate (std::string& value)
{
  return true;
}

////////////////////////////////////////////////////////////////////////////////
// Set the minimum and maximum widths for the value.
void ColumnFg::measure (Task& task, int& minimum, int& maximum)
{
  std::string fg = task.get (_name);

  minimum = longestWord (fg);
  maximum = fg.length ();
}

////////////////////////////////////////////////////////////////////////////////
void ColumnFg::render (
  std::vector <std::string>& lines,
  Task& task,
  int width,
  Color& color)
{
  std::string fg = task.get (_name);

  std::vector <std::string> raw;
  wrapText (raw, fg, width, _hyphenate);

  std::vector <std::string>::iterator i;
  for (i = raw.begin (); i != raw.end (); ++i)
    lines.push_back (color.colorize (leftJustify (*i, width)));
}

////////////////////////////////////////////////////////////////////////////////
