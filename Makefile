
TARGET=./bin
export FGLLDPATH=$(TARGET)
export FGLRESOURCEPATH=$(PWD)/etc
export FGLIMAGEPATH=$(PWD)/pics:$(FGLDIR)/lib/image2font.txt

all: $(TARGET) \
	$(TARGET)/gl_lib.42m \
	$(TARGET)/matDesTest.42m \
	$(TARGET)/matDesTest_forms.42f \
	$(TARGET)/matDesTest_modal.42f \
	$(TARGET)/matDesTest.42f

$(TARGET) :
	mkdir $(TARGET)

$(TARGET)/gl_lib.42m: src/lib/gl_lib.4gl
	fglcomp -o $(TARGET) -Wall $^

$(TARGET)/matDesTest.42m: src/matDesTest.4gl
	fglcomp -o $(TARGET) -I src/lib -Wall $^

$(TARGET)/matDesTest_forms.42f: src/matDesTest_forms.per
	fglform $^ && mv src/*.42f $(TARGET)

$(TARGET)/matDesTest_modal.42f: src/matDesTest_modal.per
	fglform $^ && mv src/*.42f $(TARGET)

$(TARGET)/matDesTest.42f: src/matDesTest.per
	fglform $^ && mv src/*.42f $(TARGET)

run: $(TARGET) $(TARGET)/gl_lib.42m $(TARGET)/matDesTest.42m
	cd $(TARGET) && fglrun matDesTest.42m

clean:
	rm -rf bin
