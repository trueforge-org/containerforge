CXXFLAGS=-Wall -O2

mp3val: main.o mpegparse.o out.o report.o crossapi.o crc.o
	$(CXX) $(CXXFLAGS) $^ -o $@

clean:
	rm -f mp3val
	rm -f *.o
