const documentsDir = `/Users/brent.whitehead/Documents`;

export const debug = async (string, version) => {
  const fsPromises = require("fs").promises;
  const posthtml = require("posthtml");
  const beautify = require("posthtml-beautify");
  const isObject = typeof string === "object";
  const isString = typeof string === "string";

  let output;
  if (isString) {
    output = string;
  } else if (isObject) {
    output = JSON.stringify(string, getCircularReplacer());
  } else {
    const html = string?.outerHTML ?? window.document.body.outerHTML;

    output = await posthtml()
      .use(beautify({ rules: { indent: 4 } }))
      .process(html);
  }

  await fsPromises.writeFile(
    `${documentsDir}/formatedHTML${version ? version : "1"}.${
      isObject ? "json" : "html"
    }`,
    string == null ? output.html : output
  );
};

export const log = async (...args) => {
  const fsPromises = require("fs").promises;
  const isObject = (string) => typeof string === "object";
  const isString = (string) => typeof string === "string";
  const myFile = documentsDir + `/log.log`;

  let log = [];

  args.forEach((item) => {
    if (isObject(item)) {
      log.push(JSON.stringify(item, getCircularReplacer()));
    }
    if (isString(item)) {
      log.push(item);
    }
  });

  await fsPromises.appendFile(myFile, log.join(" ") + "\r");
};

export const clear = async () => {
  const myFile = documentsDir + `/log.log`;
  const fs = require("fs");
  fs.truncateSync(myFile, 0);
};

const getCircularReplacer = () => {
  const seen = new WeakSet();
  return (key, value) => {
    if (typeof value === "object" && value !== null) {
      if (seen.has(value)) {
        return;
      }
      seen.add(value);
    }
    return value;
  };
};
