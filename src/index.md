---
layout: default
---

# About me

Hi, I'm Marco, your friendly neighborhood engineer!

This is my personal home on the Internet.

{% assign author = site.data.authors[site.author_id] %}
{% if author.cv_urls %}
Here's my curriculum vitae (CV): {% assign cv_urls = author.cv_urls %}{% for url in cv_urls %}[{{ url.language }}]({{ url.url }}){% endfor %}
{% endif %}

## Contacts

{% include contacts_list.html %}

{% if site.data.publications %}

## Publications

{% include publication_list.html %}

{% endif %}

{% if site.posts %}

## Posts

{% include post_list.html %}

{% endif %}
