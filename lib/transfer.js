const canvas = require("canvas");
const { writeFileSync } = require("node:fs");
const path = require("node:path");
const process = require("node:process");
const util = require("node:util");

util.inspect.defaultOptions.maxArrayLength = null;

let args = process.argv;
let env = {
    fileName: "out",
    fileLocation: "./",
};

// Ignore first 2 arguments, they're the process and this file.
const jsonProcess = JSON.parse(args[2]);

// console.log(`<Debug ${args[2]}>`);

let { width, height, type } = jsonProcess;
const cvn = canvas.createCanvas(width, height, type);
const ctx = cvn.getContext("2d");

for (let i = 0; i < jsonProcess.commands.length; i++) {
    const cmd = jsonProcess.commands[i];
    const cmdArgs = [...cmd];
    const cmdName = cmdArgs.shift();
    const cmdScope = cmdArgs.shift();

    // console.log(`<Debug ${cmdName}, ${cmdScope}>`);
    if (cmdName === "createImage" && cmdScope == "Canvas") {
        const TYPE = cvn.type == "image" ? "png" : cvn.type;
        const PATH = path.join(env.fileName + "." + TYPE);
        console.log(`<Path ${PATH}>`);
        writeFileSync(PATH, cvn.toBuffer());
    }

    switch (cmdScope) {
        case "Context":
            if (typeof ctx[cmdName] != "function") ctx[cmdName] = cmdArgs[0];
            else if (ctx[cmdName]) {
                let result = ctx[cmdName].call(ctx, ...cmdArgs);

                if (result) console.log(JSON.stringify(result));
            } else console.log(`Invalid method '${cmdName}'!`);
            break;
        case "Canvas":
            if (typeof cvn[cmdName] != "function") cvn[cmdName] = cmdArgs[0];
            else if (cvn[cmdName]) {
                if (cmdName == "toBuffer")
                    return console.log(
                        // Adding the buffer keyword back in, this way the Luau
                        // script understands to clean this output and to
                        // convert into a Luau buffer.
                        "<Buffer " +
                            cvn[cmdName]
                                .call(cvn, ...cmdArgs)
                                .toString("hex")
                                .match(/../g)
                                .join(" ") +
                            ">"
                    );
                else cvn[cmdName].call(cvn, ...cmdArgs);
            } else console.log(`Invalid method '${cmdName}'!`);
            break;
        case "Env":
            if (env[cmdName]) env[cmdName] = cmdArgs;
            break;
        default:
            console.log(`Invalid scope '${cmdScope}'!`);
            break;
    }
}
