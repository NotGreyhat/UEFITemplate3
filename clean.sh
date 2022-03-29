for i in $(find ./ -type f -name "*.o")
do
    rm $i
done

for i in $(find ./ -type f -name "*.d")
do
    rm $i
done
