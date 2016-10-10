Needs["CCompilerDriver`"];

$MongoLink = FileNameJoin[{DirectoryName[$InputFileName], "..", "Libraries", "MongoLink"}];

$MathLink = FileNameJoin[{AntProperty["checkout_directory"], "MathLink", "CompilerAdditions"}];
$MongoC = FileNameJoin[{AntProperty["checkout_directory"], "MongoC"}];
$RuntimeLibrary = FileNameJoin[{AntProperty["checkout_directory"], "RuntimeLibrary", AntProperty["system_id"]}];

$MongoLinkLib = CreateLibrary[

	FileNames["*.cpp", {$MongoLink}],
	"MongoLink",

	"CleanIntermediate" -> True,

	"CompileOptions" ->
		Switch[$OperatingSystem,
			"MacOSX",	"-std=c++11",
			"Unix",		"-std=c++11 -Wl,-rpath=/usr/local/lib",
			"Windows",	"/EHsc"
		],

	"CompilerInstallation" ->
		Switch[$OperatingSystem,
			"MacOSX",	Automatic,
			_,			Environment["COMPILER_INSTALLATION"]
		],

	"IncludeDirectories"-> {
		$MongoLink,
		FileNameJoin[{$MongoC, "include", "libmongoc-1.0"}],
		FileNameJoin[{$MongoC, "include", "libbson-1.0"}]
		},

	"Language" -> "C++",

	"Libraries" ->
		Switch[$OperatingSystem,
			"MacOSX",	{ "mongoc-1.0.0", "bson-1.0.0" },
			"Unix",		{ "mongoc-1.0",   "bson-1.0"   },
			"Windows",	{ "mongoc-1.0",   "bson-1.0" }
		],

	"LibraryDirectories" -> {
		FileNameJoin[{$MongoC, "lib"}]
		},

	"ShellCommandFunction" -> Global`AntLog,
	"ShellOutputFunction" -> Global`AntLog,

	"SystemIncludeDirectories" -> {
		FileNameJoin[{$MathLink, "mldev32", "include"}],
		FileNameJoin[{$MathLink, "mldev64", "include"}],
		FileNameJoin[{$MathLink}],
		$RuntimeLibrary
		},

	"SystemLibraryDirectories" -> Switch[$OperatingSystem,
		"MacOSX",
			{
			"-F" <> $MathLink,
			$RuntimeLibrary
			},
		_,
			{
			FileNameJoin[{$MathLink, "mldev32", "lib"}],
			FileNameJoin[{$MathLink, "mldev64", "lib"}],
			$MathLink,
			$RuntimeLibrary
			}
		],

	"TargetDirectory" -> FileNameJoin[{AntProperty["files_directory"], AntProperty["component"], "LibraryResources", AntProperty["system_id"]}],
	"TargetSystemID" -> AntProperty["system_id"],

	"WorkingDirectory" -> AntProperty["scratch_directory"]
	];

If[FailureQ[$MongoLinkLib], AntFail["Library was not generated."]];