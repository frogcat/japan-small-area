const fs = require("fs");
const wellknown = require("wellknown");
const simplify = require("@turf/simplify");

const dig = function(a) {
  const fix = function(src) {
    const dst = [];
    src.forEach(p => {
      const q = p.map(v => parseFloat(v.toFixed(5)));
      if (dst.length === 0 || dst[dst.length - 1][0] !== q[0] || dst[dst.length - 1][1] !== q[1])
        dst.push(q);
    });
    return dst.length < 4 ? src : dst;
  };
  switch (a.type) {
    case "Polygon":
      a.coordinates = a.coordinates.map(fix);
      break;
    case "MultiPolygon":
      a.coordinates = a.coordinates.map(polygon => polygon.map(fix));
      break;
  }
};

const sac = {};


const data = {};

Array.from(process.argv).slice(2).forEach(file => {
  JSON.parse(fs.readFileSync(file, "UTF-8")).results.bindings.forEach(a => {
    const key = a.s.value;
    if (data[key] === undefined) data[key] = {};
    Object.keys(a).forEach(b => {
      data[key][b] = a[b].value;
    });
  });
});

console.log('{"type":"FeatureCollection","features":[');

Object.values(data).filter(a => a.wkt !== undefined).forEach((a, i, list) => {
  let geometry = wellknown.parse(a.wkt.replace(/^<[^>]*> /, ""));
  dig(geometry);
  let geojson = {
    type: "Feature",
    id: a.s,
    geometry: geometry,
    properties: {}
  };

  Object.keys(a).filter(b => b !== "s" && b !== "wkt").forEach(b => {
    geojson.properties[b] = a[b];
  });

  if (geojson.properties.parent) {
    let names = [geojson.properties.label];
    let focus = geojson.properties.parent;
    while (focus) {
      const x = data[focus];
      if (x) {
        if (x.label && x.label.match(/[都道府県郡市区町村]$/))
          names.unshift(x.label);
        if (x.gun)
          names.unshift(x.gun);
        focus = x.parent;
      } else {
        focus = null;
      }
    }
    geojson.properties.fullname = names.join("/");
  }

  try {
    geojson = simplify(geojson, {
      tolerance: 0.0002,
      mutated: true
    });
  } catch (e) {
    console.error(e);
    console.error(a.s);
    return;
  }

  console.log(JSON.stringify(geojson) + (i < list.length - 1 ? "," : ""));
});

console.log(']}');
