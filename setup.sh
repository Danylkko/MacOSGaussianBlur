git submodule update --remote
cd task_9
mkdir build
cd build
conan install ..
cmake ..
cmake --build .
cd ..
cd ..
pod install
