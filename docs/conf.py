import datetime
import os
import re
import textwrap

# Configuration for the Sphinx documentation builder.
# All configuration specific to your project should be done in this file.
#
# If you're new to Sphinx and don't want any advanced or custom features,
# just go through the items marked 'TODO'.
#
# A complete list of built-in Sphinx configuration values:
# https://www.sphinx-doc.org/en/master/usage/configuration.html
#
# The project uses the Canonical Sphinx theme.
# https://canonical-sphinx.readthedocs-hosted.com/

#######################
# Project information #
#######################

# Release profile. A new release branch should only need to change these values,
# plus the concrete files listed below.
product_release = "24.04"
upstream_release = "3.7"
sdk_ng_channel = "0.16.9/stable"
source_tag = "24.04.rc-1"

# Keep docs/reference/workshop.yaml, the release-note filename and heading,
# toctree entries, page labels, and reST metadata descriptions aligned with the
# profile. These are consumed outside normal reST substitution processing.
product_name = f"Zephyr {product_release}"
upstream_docs_release = f"{upstream_release}.0"
workshop_name = f"zephyr-{product_release.replace('.', '-')}"
workshop_definition = f"{workshop_name}.yaml"
workshop_base = f"ubuntu@{product_release}"
workshop_sdk_channel = f"{product_release}/stable"
launchpad_project_url = "https://code.launchpad.net/~arctic-tern/zephyr-rtos"
launchpad_git_base = "https://git.launchpad.net/~arctic-tern/zephyr-rtos/+git"
manifest_repository = "zephyr-manifest"
manifest_repository_url = f"{launchpad_git_base}/{manifest_repository}"

# Project name
project = product_name

# Author name; used in the default copyright statement in the page footer
author = "Canonical Ltd."

# The year in the copyright statement
copyright = f"{datetime.date.today().year}"

# Sidebar documentation title; empty to defer to the theme default.
html_title = ""

# Documentation website URL
ogp_site_url = os.environ.get("READTHEDOCS_CANONICAL_URL", "/")

# Preview name of the documentation website
ogp_site_name = project

# Preview image URL
# TODO: To customise the preview image, update the next line.
ogp_image = "https://assets.ubuntu.com/v1/cc828679-docs_illustration.svg"

# Product favicon; shown in bookmarks, browser tabs, etc.
# TODO: To customise the favicon, uncomment and update the next line.
# html_favicon = ".sphinx/_static/favicon.png"

# Dictionary of values to pass into the Sphinx context for all pages:
# https://www.sphinx-doc.org/en/master/usage/configuration.html#confval-html_context
html_context = {
    # Product page URL; can be different from product docs URL
    # TODO: Change to your product website URL, dropping the 'https://' prefix (e.g.,
    #       'ubuntu.com/lxd'). If there's no such website, remove the {{ product_page }}
    #       link from the _templates/header.html file.
    "product_page": "documentation.ubuntu.com",
    # Product tag image; the orange part of your logo, shown in the page header
    # TODO: To add a tag image, uncomment and update as needed.
    # 'product_tag': '_static/tag.png',
    # Your Discourse instance URL
    # TODO: Change to your Discourse instance URL or leave empty.
    "discourse": "",
    # Your Mattermost channel URL
    # TODO: Change to your Mattermost channel URL or leave empty.
    "mattermost": "",
    # Your Matrix channel URL
    # TODO: Change to your Matrix channel URL or leave empty.
    "matrix": "",
    # Your documentation GitHub repository URL If set, links for viewing the
    # documentation source files and creating GitHub issues are added at the bottom of
    # each page.
    # TODO: Change to your documentation GitHub repository URL or leave empty.
    "github_url": "https://github.com/canonical/zephyr-lts-docs",
    # Docs branch in the repo; used in links for viewing the source files
    "repo_default_branch": "main",
    # Docs location in the repo; used in links for viewing the source files
    "repo_folder": "/docs/",
    # TODO: To enable or disable the Previous / Next buttons at the bottom of pages
    # Valid options: none, prev, next, both
    # "sequential_nav": "",
    # TODO: To enable listing contributors on individual pages, set to True
    "display_contributors": False,
    # Required for feedback button
    "github_issues": "enabled",
    # Passes the top-level 'author' value to the theme
    "author": author,
    # Documentation license information
    "license": {
        # TODO: Specify your project's license.
        # For the name, we recommend using the standard shorthand identifier from
        # https://spdx.org/licenses
        "name": "GPL-3.0",
        # TODO: Link directly to your project's license statement.
        "url": "https://www.gnu.org/licenses/gpl-3.0.html",
    },
}

html_theme_options = {
    "source_edit_link": "https://github.com/canonical/zephyr-lts-docs",
}

# Project slug
# TODO: If your documentation is hosted on https://documentation.ubuntu.com/,
#       uncomment and set to the RTD slug.
# slug = ''

#######################
# Sitemap configuration: https://sphinx-sitemap.readthedocs.io/
#######################

# Use RTD canonical URL to ensure duplicate pages have a specific canonical URL
html_baseurl = os.environ.get("READTHEDOCS_CANONICAL_URL", "/")

# sphinx-sitemap uses html_baseurl to generate the full URL for each page:
sitemap_url_scheme = "{link}"

# Include `lastmod` dates in the sitemap:
sitemap_show_lastmod = True

# TODO: Exclude pages that aren't user-facing from the sitemap (e.g., module pages
# generated by autodoc).
# Pages excluded from the sitemap:
sitemap_excludes = [
    "404/",
    "genindex/",
    "search/",
]

################################
# Template and asset locations #
################################

# html_static_path = ["_static"]
# templates_path = ["_templates"]

#############
# Redirects #
#############

# Add redirects to the 'redirects.txt' file
# https://sphinxext-rediraffe.readthedocs.io/en/latest/

# To set up redirects in the Read the Docs project dashboard:
# https://docs.readthedocs.io/en/stable/guides/redirects.html

rediraffe_redirects = "redirects.txt"

# Strips '/index.html' from destination URLs when building with 'dirhtml'
rediraffe_dir_only = True


############################
# sphinx-llm configuration #
############################

# This description is included in llms.txt to provide some initial context for your
# product docs.
# TODO: Add a description in the form "This is the documentation for <product name>,
# <first sentence of home page>".
llms_txt_description = textwrap.dedent(
    f"""\
    This is the documentation for {product_name}, Canonical's long-term support
    distribution of the Zephyr real-time operating system.
    """
)

# The base URL for references built by sphinx-markdown-builder.
if os.environ.get("READTHEDOCS"):
    markdown_http_base = html_baseurl

###########################
# Link checker exceptions #
###########################

# A regex list of URLs that are ignored by 'make linkcheck'
linkcheck_ignore = [
    "http://127.0.0.1:8000",
    rf"{re.escape(launchpad_project_url)}.*",
    rf"{re.escape(launchpad_git_base)}.*",
    r"https://github\.com/canonical/zephyr-lts-docs(?:/.*)?$",
    r"https://matrix\.to/.*",
    "https://example.com",
    # SourceForge domains often block linkcheck
    r"https://.*\.sourceforge\.(net|io)/.*",
]

# A regex list of URLs where anchors are ignored by 'make linkcheck'
linkcheck_anchors_ignore_for_url = [r"https://code\.launchpad\.net/.*"]

# How long the link checker will wait for a response for each request
# TODO: Decrease to improve run time or increase if links frequently time out.
# linkcheck_timeout = 30

# Give linkcheck multiple tries on failure
linkcheck_retries = 3

########################
# Configuration extras #
########################

# Custom MyST syntax extensions; see
# https://myst-parser.readthedocs.io/en/latest/syntax/optional.html
# NOTE: By default, the following MyST extensions are enabled:
#   - substitution
#   - deflist
#   - linkify
# myst_enable_extensions = set()

# Custom Sphinx extensions; see
# https://www.sphinx-doc.org/en/master/usage/extensions/index.html
extensions = [
    "canonical_sphinx",
    "notfound.extension",
    "sphinx_design",
    "sphinx_rerediraffe",
    "sphinx_reredirects",
    "sphinx_tabs.tabs",
    "sphinxcontrib.jquery",
    "sphinxext.opengraph",
    "sphinx_config_options",
    "sphinx_contributor_listing",
    "sphinx_filtered_toctree",
    "sphinx_llm.txt",
    "sphinx_related_links",
    "sphinx_roles",
    "sphinx_terminal",
    "sphinx_ubuntu_images",
    "sphinx_youtube_links",
    "sphinxcontrib.cairosvgconverter",
    "sphinx_last_updated_by_git",
    "sphinx.ext.intersphinx",
    "sphinx.ext.extlinks",
    "sphinx.ext.todo",
    "sphinx_sitemap",
]

#####################
# External link shortcuts
#####################

# Shortcut roles for linking to external sites; see
# https://www.sphinx-doc.org/en/master/usage/extensions/extlinks.html
#
# Usage: :zephyr37-docs:`develop/west/manifest.html <West Manifests>` links
# to https://docs.zephyrproject.org/3.7.0/develop/west/manifest.html with the
# link text "West Manifests". Omitting the "<...>" part uses the path itself
# as the link text.
extlinks = {
    "zephyr37-docs": ("https://docs.zephyrproject.org/3.7.0/%s", "%s"),
}

#####################
# Todo extension
#####################

# Enables the `.. todo::` directive and `todolist` directive; see
# https://www.sphinx-doc.org/en/master/usage/extensions/todo.html
#
# Set to False (or remove) before publishing a release build if you don't
# want TODOs to appear in the rendered output.
todo_include_todos = True

# Excludes files or directories from processing
exclude_patterns = [
    "doc-cheat-sheet*",
    ".venv*",
    "_dev",
]

# Adds custom CSS files, located remotely or in 'html_static_path'.
# html_css_files = [
#     "https://assets.ubuntu.com/v1/d86746ef-cookie_banner.css",
# ]

# Adds custom JavaScript files, located remotely or in 'html_static_path'.
# html_js_files = [
#     "https://assets.ubuntu.com/v1/287a5e8f-bundle.js",
# ]

# Appends release substitutions and reusable external links to every reST page.
rst_epilog = f"""
.. |product_name| replace:: {product_name}
.. |product_release| replace:: {product_release}
.. |upstream_release| replace:: {upstream_release}
.. |upstream_docs_release| replace:: {upstream_docs_release}
.. |workshop_name| replace:: {workshop_name}
.. |workshop_definition| replace:: {workshop_definition}
.. |workshop_base| replace:: {workshop_base}
.. |workshop_sdk_channel| replace:: {workshop_sdk_channel}
.. |sdk_ng_channel| replace:: {sdk_ng_channel}
.. |source_tag| replace:: {source_tag}
.. |launchpad_project_url| replace:: {launchpad_project_url}
.. |launchpad_git_base| replace:: {launchpad_git_base}
.. |manifest_repository| replace:: {manifest_repository}
.. |manifest_repository_url| replace:: {manifest_repository_url}
.. |product_release_samp| replace:: :samp:`{product_release}`
.. |upstream_release_samp| replace:: :samp:`{upstream_release}`
.. |workshop_name_samp| replace:: :samp:`{workshop_name}`
.. |workshop_definition_file| replace:: :file:`.workshop/{workshop_definition}`
.. |workshop_base_samp| replace:: :samp:`{workshop_base}`
.. |workshop_sdk_channel_samp| replace:: :samp:`{workshop_sdk_channel}`
.. |sdk_ng_channel_samp| replace:: :samp:`{sdk_ng_channel}`
.. |source_tag_samp| replace:: :samp:`{source_tag}`
.. |manifest_repository_url_samp| replace:: :samp:`{manifest_repository_url}`
.. |workshop_project_prompt| replace:: workshop\\@{workshop_name}:/project$
.. |workshop_zephyr_prompt| replace:: workshop\\@{workshop_name}:/project/zephyr$
.. |workshop_info_command| replace:: :command:`workshop info {workshop_name}`
.. |manifest_tag_command| replace:: :command:`git -C {manifest_repository} describe --tags --exact-match`
.. |workshop_sync_command| replace:: :command:`workshop run {workshop_name} -- sync`
.. |workshop_build_command| replace:: :command:`workshop run {workshop_name} -- build -b qemu_x86 samples/hello_world`
.. |workshop_flash_command| replace:: :command:`workshop run {workshop_name} -- flash`
.. |Workshop| replace:: **Workshop**

.. _Zephyr RTOS Launchpad project: {launchpad_project_url}
.. _Zephyr manifest repository: {launchpad_project_url}/+git/{manifest_repository}
.. _Zephyr source repository: {launchpad_project_url}/+git/zephyr
.. _MCUboot repository: {launchpad_project_url}/+git/mcuboot
.. _CMSIS repository: {launchpad_project_url}/+git/cmsis
.. _Nordic HAL repository: {launchpad_project_url}/+git/hal_nordic
.. _STM32 HAL repository: {launchpad_project_url}/+git/hal_stm32
.. _sdk-ng repository: {launchpad_project_url}/+git/sdk-ng
.. _upstream Zephyr SDK installation procedure: https://docs.zephyrproject.org/{upstream_docs_release}/develop/toolchains/zephyr_sdk.html
.. _Diátaxis documentation framework: https://diataxis.fr/
.. _License: https://github.com/canonical/zephyr-lts-docs/blob/main/LICENSE
.. _Report a documentation issue: https://github.com/canonical/zephyr-lts-docs/issues
.. _Security policy: https://github.com/canonical/zephyr-lts-docs/blob/main/SECURITY.md
.. _Ubuntu Code of Conduct: https://ubuntu.com/community/docs/ethos/code-of-conduct
.. _Workshop: https://ubuntu.com/workshop
"""

# Feedback button at the top; enabled by default
disable_feedback_button = True

# Your manpage URL
# TODO: To enable manpage links, uncomment and replace {codename} with required
#       release, preferably an LTS release (e.g. noble). Do *not* substitute
#       {section} or {page}; these will be replaced by sphinx at build time
#
# NOTE: If set, adding ':manpage:' to an .rst file
#       adds a link to the corresponding man section at the bottom of the page.
# manpages_url = 'https://manpages.ubuntu.com/manpages/{codename}/en/' + \
#     'man{section}/{page}.{section}.html'

# Specifies a reST snippet to be prepended to each .rst file
# This defines a :center: role that centers table cell content.
# This defines a :h2: role that styles content for use with PDF generation.
rst_prolog = """
.. role:: center
   :class: align-center
.. role:: h2
    :class: hclass2
.. role:: woke-ignore
    :class: woke-ignore
.. role:: vale-ignore
    :class: vale-ignore
"""

# Configuration for Intersphinx projects
#
# intersphinx_mapping = {
#     "snap": ("https://snapcraft.io/docs/", None),
# }
