# -*- coding: utf-8 -*-
#
# Simple documentation build configuration file

# -- General configuration ------------------------------------------------

extensions = []
templates_path = ['_templates']

# General information about the project.
project = u'Documentation for Stanford Dynamic PET Data Processing'
copyright = u'2021, Stanford University'
author = u'Moss Zhao'
master_doc = 'index'
version = u''
release = u''
source_suffix = ['.rst',]
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# -- Options for HTML output ----------------------------------------------

try:
    import sphinx_rtd_theme
    html_theme = "sphinx_rtd_theme"
    html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]
except ImportError:
    html_theme = 'alabaster'

# -- Options for LaTeX output ---------------------------------------------

latex_documents = [
    (master_doc, 'doc_stanford_pet.tex', project, author, 'manual'),
]
