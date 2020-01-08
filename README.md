# Dynamic Dark Mode

<a href="https://www.producthunt.com/posts/dynamic-dark-mode?utm_source=badge-featured" target="_blank" id="product-hunt"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=145745&theme=light" alt="Dynamic Dark Mode - The smart, automatic Dark Mode toggle for macOS Mojave | Product Hunt Embed" style="height: 50px;" height="50px" /></a>

*Dynamic Dark Mode* is the app you are looking for to power up Dark Mode on macOS Mojave.

Instead of looking for the switch for dark mode in System Preferences, just click the icon in the menu bar. Ever felt your eyes getting hurt because the screen is so bright in the night? Have to worry no more, we Dynamically enable dark mode in dim lights, after sunset, or just anytime. When you wake up in the morning, it'll a be another bright day.

![Settings for Dynamic Dark Mode](https://user-images.githubusercontent.com/10842684/54065701-b240e800-41f2-11e9-8f7a-5d502ab27c4e.png)

## Install

### Via [Homebrew Cask](https://brew.sh/) (Recommended)

```
brew cask install dynamic-dark-mode
```

### Direct Download

<details>
  <summary><a href="https://github.com/ApolloZhu/Dynamic-Dark-Mode/releases/latest">Latest Release</a></summary>

  Additionally, you may also download:

  <ul>
    <li><a href="https://rebrand.ly/ddm-nightly" target="_blank">Nightly Build</a></li>
    <li><a href="https://github.com/ApolloZhu/Dynamic-Dark-Mode/releases">Earlier Releases</a></li>
    <li><a href="https://rebrand.ly/ddm-all" target="_blank">Earlier Builds</a></li>
  </ul>

</details>

## License

```
Dynamic Dark Mode - the smart, automatic Dark Mode toggle for macOS
Copyright (C) 2018-2020 Zhiyu Zhu (@ApolloZhu)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```

<details>
<summary></summary>

<script type="text/javascript">
  window.onload = function () {
    document.getElementsByClassName("project-name")[0].innerHTML = "Dynamic Dark Mode";
    document.getElementById("dynamic-dark-mode").style.display="none";
    pageHeader = document.getElementsByClassName("page-header")[0];
    pageHeader.insertAdjacentHTML('beforeend', '<a href="https://github.com/ApolloZhu/Dynamic-Dark-Mode/releases/latest" class="btn">Download</a>');
    pageHeader.insertAdjacentHTML('beforeend', '<a href="#install" class="btn">Homebrew Cask</a>');
    productHunt = document.getElementById("product-hunt")
    pageHeader.append(productHunt)
    productHunt.setAttribute('style', 'padding: 0;border-width: 0;height: 50px;background-color: transparent;vertical-align: bottom;')
    productHunt.setAttribute('class', 'btn')
  }
</script>

</details>
