---
layout: post
title: Blog
permalink: /blog/
include_rss_link: true
additional_css_classes: "post-list"
---

<ul>
{% for post in site.posts %}
  {% include post_list_item.html date=post.date url=post.url title=post.title %}
{% endfor %}
</ul>
