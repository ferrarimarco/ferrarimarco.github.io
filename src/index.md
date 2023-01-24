---
layout: default
---

{% include contacts_list.html %}

Hi, I'm Marco, your friendly neighborhood engineer!

{% assign author = site.data.authors[site.author_id] %}
{% if author.cv_urls %}
Here's my curriculum vitae (CV): {% assign cv_urls = author.cv_urls %}{% for url in cv_urls %}[{{ url.language }}]({{ url.url }}){% endfor %}
{% endif %}

I currently work as a Cloud Solutions Architect at Google. My team takes care of
solving the hardest technical issues, and first-of-a-kind problems. Then, we
distill the knowledge we gathered so that other teams can benefit from what we
learned.

You can find some examples of what I wrote in the [Publications section](#publications).

My current focus is migrations (from other cloud providers and on premises
environments) to Google Cloud, automation,
[DevOps](https://en.wikipedia.org/wiki/DevOps), and
[Site Reliability Engineering (SRE)](https://en.wikipedia.org/wiki/Site_reliability_engineering).

{% if site.data.publications and site.data.publications.size != 0 %}

## Publications

{% include publication_list.html %}

{% endif %}

{% if site.posts and site.posts.size != 0 %}

## Posts

{% include post_list.html %}

{% endif %}
