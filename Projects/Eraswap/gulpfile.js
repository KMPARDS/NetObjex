var gulp = require('gulp');
var path = require("path");
var fs = require('fs');
var del = require('del');
var gulpSequence = require('gulp-sequence');
var moment = require('moment-timezone');
var BigNumber = require('bignumber.js');

var processed_files = [], pragma_processed = false;

function getUnixTime(x){
    return moment.tz(x, "America/Los_Angeles").valueOf()/1000;
}

function expand_file(src, parent_path, reset) {
    if (reset) {
        pragma_processed = false;
        processed_files = [];
    }
    var absolutePath = !parent_path ? path.resolve(src) : path.resolve(parent_path + '/' + src);

    var current_path = path.dirname(absolutePath);

    if (processed_files.indexOf(absolutePath) != -1)
        return;
    console.log("Expanding source code file ", absolutePath);

    var data = fs.readFileSync(absolutePath, 'utf8');

    processed_files.push(absolutePath);
    return process_source(data, current_path);
}

function process_source(src, parent_path) {
    var out = [];
    var line = "";
    var data = src.split("\n");

    for (var i = 0; i < data.length; i++) {

        line = data[i];
        if (line.indexOf("import '") == 0) {
            var _import = line.split("'");

            var source = expand_file(_import[1], parent_path);
            if (source)
                out = out.concat(source.split("\n"));
        } else if (line.indexOf('import "') == 0) {
            var _import = line.split('"');
            var source = expand_file(_import[1], parent_path);
            if (source)
                out = out.concat(source.split("\n"));
        } else if (line.indexOf('pragma ') == 0) {
            if (pragma_processed)
                continue;
            else {
                pragma_processed = true;
                out.push(line);

            }
        } else {
            out.push(line);
        }

    }
    return out.join('\n');

}

function combineSolidity(path, name){
    var combinedsource = expand_file(path, '', true);
    fs.writeFile("./contracts/"+name+".sol", combinedsource, function (err) {
        if (err) {
            return console.log(err);
        }

        console.log("The file "+name+" was processed!");
    });
}
gulp.task('combine_solidity', ['clean'], function () {
    combineSolidity('./contracts_dev/Migrations.sol',"Migrations");
    // combineSolidity('./contracts_dev/EraswapToken.sol', "EraswapToken");
    // combineSolidity('./contracts_dev/NRTManager.sol', "NRTManager");
    combineSolidity('./contracts_dev/ERC20Mock.sol', "ERC20Mock");
});

gulp.task('clean', [], function () {
    return del([
        'contracts/*.sol'
    ]);

});


gulp.task('generate_constructor', [], function () {
    var Web3EthAbi = require('web3-eth-abi');
    var mainAddress = '0xd89b0356d41dc9de0fa98eecd4c1dd908dfe0bab';
    // var encoded = Web3EthAbi.encodeParameters(['string','string','uint','uint','bool'], ['IoToken', 'ITC', new BigNumber(5000000000000000000000000000) , 18, 0]);

    var encoded = Web3EthAbi.encodeParameters(['address', 'uint', 'uint'],
        [mainAddress, "1000000000000000000000000000" , "1000000000000000000000000000"]
    );
    console.log(encoded);
    // var encoded = Web3EthAbi.encodeParameters(['uint[]'], [[
    //     getUnixTime("2017-08-07T00:00:00"), 178571428571428,
    //     getUnixTime("2017-10-11T00:00:00"), 0 ,
    //     getUnixTime("2017-12-08T00:00:00"), 178571428571428*2,
    //     getUnixTime("2018-01-11T00:00:00"), 0,
    //     getUnixTime("2050-01-11T00:00:00"), 0, //terminate the sale
    //
    // ]]);
    // console.log(encoded);
    // var encoded = Web3EthAbi.encodeParameters(['address','address','address','uint','uint','uint','address'],
    //     [
    //         "0xd45e62c5ae0fa84a40e6ce06ca9129ec51923e62",
    //         "0x238ea74d59538cc2b5da55201b2822f3a2012275",
    //     "0x02899893639f238031C91a8BfD798CE009a12235",
    //     getUnixTime("2017-08-07T00:00:00"),
    //     getUnixTime("2050-01-11T00:00:00"),
    //     100000000000000000000,
    //     "0x02899893639f238031C91a8BfD798CE009a12235"
    // ]);
    // console.log(encoded);
    // var encoded = Web3EthAbi.encodeParameters(['address'],
    //     [
    //         "0x6997f915413c1cbf6192e85d911ea4b87cff3ca1"
    //
    // ]);
    // console.log(encoded);

});


gulp.task('combine', gulpSequence('combine_solidity'));
gulp.task('default', gulpSequence('combine_solidity'));
gulp.task('generateabi', gulpSequence('generate_constructor'));
