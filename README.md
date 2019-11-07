# japan-small-area

日本国内の小地域ポリゴンを GeoJSON として 整備したものです。

# Data source

[e-Stat 統計LOD](https://data.e-stat.go.jp/lodw/) の SPARQL Endpoint から取得した
2015年の国勢調査のデータを使用しています。

# Demo

- <https://frogcat.github.io/japan-small-area/>

# Files

- GeoJSON ファイルの実体は [docs](https://github.com/frogcat/japan-small-area/tree/master/docs) フォルダに収録しています
- 都道府県ごとに作成された `docs/01.json` ～ `docs/47.json` の 47ファイルです
- <https://frogcat.github.io/japan-small-area/01.json> ～ <https://frogcat.github.io/japan-small-area/47.json> から直接取得することもできます

# Structure

各 GeoJSON は以下のようなデータ構造になっています。

```example.json
{
  "type": "FeatureCollection",
  "features": [{
      "type": "Feature",
      "id": "http://data.e-stat.go.jp/lod/smallArea/g00200521/2015/S13115031003",
      "properties": {
        "population": "4308",
        "households": "2623",
        "label": "松庵３丁目",
        "parent": "http://data.e-stat.go.jp/lod/sac/C13115-19700401",
        "fullname": "東京都/杉並区/松庵３丁目"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [139.59813, 35.69937],
            [139.5998, 35.70288],
            [139.59813, 35.70388],
            [139.59443, 35.70374],
            [139.59284, 35.70087],
            [139.59764, 35.69836],
            [139.59813, 35.69937]
          ]
        ]
      }
    },
    ...
  ]
}
```

## FeatureCollection

- ルートは `FeatureCollection` です
- `features` に `Feature` の配列を保持します

## Feature

2015年の国勢調査における小地域に対応する `Feature` です

### geometry

- `Polygon` または `MultiPolygon` です
- サイズ抑制のために [@turf/simplify](https://www.npmjs.com/package/@turf/simplify) で処理されています

### properties

以下のプロパティを保持しています

- `population` : 2015年の国勢調査における小地域の人口 (optional)
- `households` : 2015年の国勢調査における小地域の世帯数 (optional)
- `label` :  2015年の国勢調査における小地域の名称
- `parent` :  この小地域の所属する自治体の地方公共団体コード(URI)
- `fullname` : この小地域のフルネーム(都道府県・郡・市区町村・区・小地域名を / で連結したもの)

また `Feature` 直下の `id` プロパティには2015年国勢調査小地域コード(URI)が設定されています。

# Build

```
$ git clone https://github.com/frogcat/japan-small-area.git
$ cd japan-small-area
$ mkdir cache
$ rm docs/*.json
$ bash main.sh
```
