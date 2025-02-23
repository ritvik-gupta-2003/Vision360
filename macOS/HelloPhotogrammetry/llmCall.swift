import Foundation
import PythonKit
PythonLibrary.useLibrary(at: "/opt/anaconda3/envs/xcode/lib/libpython3.9.dylib")

let sys = Python.import("sys")

sys.path.append("/Users/mahadfaruqi/Desktop/BoilermakeXcode/BoilermakeXcode")
print("sys.path =", sys.path)

let script = Python.import("description")
print("Generating caption...")
let result = script.run("images")
print(result)
