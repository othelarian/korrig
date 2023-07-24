# Korrig Project

# needed

Here's the key components of Korrig:

- a menu bar
- two panels/column
- a way to check "global" settings
- article (can't be really separated to a plugin)
- tags (with hidden)
- icons (heroicons or lucide, full svg)

## What's an article?

An article is composed by:

- a name
- a slug (to reference it)
- a content
- a list of tags
- optional: properties (hashmap?)

NOTE: article writing system may be replaced (maybe the markdown plugin?)

## The store model

The store model must take care of:

- current settings
- the articles
- the tags (and the slugs related to them)

It means the tags can be retrieved from the articles.

## To save

This is the part I need to save to make the quine:

- the code of the page itself
- the settings state
- the articles
- the plugins

## Settings

What the settings contains?

- style selected and the available ones
- plugins installed and enabled
- for each settings, the parameters setted for it
- a way to add new plugins

## Menu bar

The menu bar contains the following elements:

- Save button(s) (classic download, or save to server)

## Panel/column and tabs

The interface is divived in two columns, called panels. The right and left panels works exactly the same way, just at a different place.

Each panel has its own store and tabs pool and menu bar. The panel menu bar, or panel bar, contains the list of all the tabs opened in the panels, and a button opening a menu to select a new tab type to open.

If the screen is too tight to show two columns then a button will help switching between both panels.

# plugins

## What's a plugin?

A plugin is an article with:

- a name
- a description (optional)
- a hasmap of article's slugs + the type (style or code)

## How the plugins are activated

- After reading the articles (see the Init sequence below) (the articles are needed to read the code)
- The setting contains the list of the plugins in the order they are loaded

## List of prioritized plugins

- markdown (the first needed)
- whiteboard plugin (using hidden tags to auto save)
- panel to full screen (deactivated if only one column size)

# Sequences

## Init

1. load the settings
2. loading the articles (needed to get the plugins code)
3. apply the style (from the setting selection)
4. get the plugins enable (special tags) and init them
5. show the interface (remove the veil?)

## Opening a tab

1. select the new tab type to open
2. create a new store dedicated to the tab
3. open the tab
