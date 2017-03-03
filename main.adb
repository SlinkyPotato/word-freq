-- Read one word per line and print list of unique words and their frequencies
-- Case sensitive
with ada.integer_text_io; use ada.integer_text_io;
with ada.text_io; use ada.text_io;
with ada.Characters.Latin_1; use Ada.Characters.Latin_1;

procedure main  is
   type OccurLN is array(1 .. 1000) of Natural;
   type Word is record
      s: String(1 .. 120);  -- The string.  Assume 120 characters or less
      wlen: Natural;        -- Length of the word
      count: Natural := 0;  -- Total number of occurrences of this word
      occursAtLine: OccurLN;
      countLN: Natural:= 0;
   end record;

   type Word_Array is array(1 .. 1000) of Word;

   type Word_List is record
      words: Word_Array;        --  The unique words
      num_words: Natural := 0;   --  How many unique words seen so far
   end record;

   procedure read_file(wl: out Word_List) is
      input: File_Type;
      found_word: Word;
      is_found: Boolean:= False;
      is_new_line: Boolean:= False;
      letter: Character;
      lineNumber: Natural:= 1;
   begin
      wl.num_words:= 0;

      put("Reading from input.txt..."); new_line;
      -- Prepare Input file
      open(File => Input, Mode => Ada.Text_IO.In_File,
           Name => "input.txt");

      -- Loop through all characters in file
      while not End_Of_File (input) loop
         declare
            is_found: Boolean:= False;
            letter_counter: Integer:= 1;
         begin 
            -- This makes sure the first letter of a new line is obtained
            if is_new_line then
               get(File => input,
                   Item => letter);
            end if;

            -- Construct the words from the current line
            while not End_Of_Line(input) loop
               if not is_new_line then
                  get(File => input,
                      Item => letter);
               end if;
               found_word.wlen:= letter_counter;
               found_word.s(letter_counter):= letter;
               letter_counter:= letter_counter + 1;
               is_new_line:= False;
            end loop;

            -- -- Loop through all known words
            for i in 1 .. wl.num_words loop
               if found_word.s(1 .. found_word.wlen) = wl.words(i).s(1 .. wl.words(i).wlen) then
                  wl.words(i).count:= wl.words(i).count + 1;
                  wl.words(i).countLN:= wl.words(i).countLN + 1;
                  wl.words(i).occursAtLine(wl.words(i).countLN):= lineNumber;
                  is_found:= True;
               end if;
               exit when is_found;
            end loop;

            -- Add the new word to the word list
            if not is_found then
               wl.num_words:= wl.num_words + 1;
               wl.words(wl.num_words).wlen:= found_word.wlen;
               wl.words(wl.num_words).s(1 .. found_word.wlen):= found_word.s(1 .. found_word.wlen);
               wl.words(wl.num_words).count:= 1;
               wl.words(wl.num_words).countLN:= wl.words(wl.num_words).countLN + 1;
               wl.words(wl.num_words).occursAtLine(wl.words(wl.num_words).countLN):= lineNumber;
            end if;
            letter_counter:= 1;
            is_new_line:= True;
            lineNumber:= lineNumber + 1;
         end;
      end loop;
      close(input);
   end read_file;

   procedure get_words(wl: out Word_List) is
   begin
      wl.num_words := 0;  -- only to get rid of a warning
      while not End_of_File loop
         declare
            s: String := Get_Line;
            found: Boolean := false;
         begin
            for i in 1 .. wl.num_words loop
               if s = wl.words(i).s(1 .. wl.words(i).wlen) then
                  wl.words(i).count := wl.words(i).count + 1;
                  found := true;
               end if;
               exit when found;
            end loop;

            if not found then -- Add word to list
               wl.num_words := wl.num_words + 1;
               wl.words(wl.num_words).s(1 .. s'last) := s;
               wl.words(wl.num_words).wlen := s'length;
               wl.words(wl.num_words).count := 1;
            end if;
         end; --  declare
      end loop;
   end get_words;

   -- Strip any spaces from the word list
   procedure strip_spaces(words: in out Word_List) is
      -- Insert a new or repeated word
      procedure insert_word(new_word: Word; words: out Word_List) is
         found: Boolean:= False;
         matching_count: Natural:= 0;
         lnCounter: Natural:= 0;
      begin
         -- Check if words list is empty, if so exit
         if (words.num_words = 0) then
            words.words(1).s(1 .. new_word.wlen):= new_word.s(1 .. new_word.wlen);
            words.num_words:= 1;
            words.words(1).count:= new_word.count;
            words.words(1).countLN:= new_word.countLN;
            words.words(1).occursAtLine:= new_word.occursAtLine;
            words.words(1).wlen:= new_word.wlen;
            found:= True;
         else
            -- put_line("new_word: " & new_word.s(1..4));
            for i in 1 .. words.num_words loop
               if (new_word.s = words.words(i).s) then
                  -- put_line("  True");
                  found:= True;
                  words.words(i).count:= new_word.count + words.words(i).count;
                  -- Check if occursAtLine from new_word matches word list
                  for k in 1 .. words.words(i).countLN loop
                     for j in 1 .. new_word.countLN loop
                        if (new_word.occursAtLine(j) = words.words(i).occursAtLine(k)) then
                           lnCounter:= lnCounter + 1;
                        end if;
                     end loop;
                  end loop;
                  -- put("word: " & words.words(i).s(1..4));
                  -- put("lnC:" & lnCounter'Image);
                  -- put_line(words.words(i).countLN'Image);
                  if (lnCounter /= new_word.countLN) then
                     -- put("words.words(i).countLN: ");
                     -- put_line(words.words(i).countLN'Image);
                     -- put("new_word.countLN: ");
                     -- put_line(new_word.countLN'Image);
                     -- put("total: ");
                     -- put_line(words.words(i).countLN'Image);
                     for k in (words.words(i).countLN + 1) .. (words.words(i).countLN + new_word.countLN) loop
                        -- put(words.words(i).s(1..4));
                        -- put("k: ");
                        -- put_line(k'Image);
                        -- put_line(new_word.occursAtLine(k - words.words(i).countLN)'Image);
                        words.words(i).occursAtLine(k):= new_word.occursAtLine(k - words.words(i).countLN);
                     end loop;
                     words.words(i).countLN:= words.words(i).countLN + new_word.countLN;
                  end if;
               end if;
            end loop;
         end if;
         if not found then
            -- put_line(new_word.s(1 .. 4));
            -- put_line(new_word.countLN'Image);
            -- put_line(new_word.occursAtLine(1)'Image);
            words.num_words:= words.num_words + 1;
            words.words(words.num_words).s(1 .. new_word.wlen):= new_word.s(1 .. new_word.wlen);
            words.words(words.num_words).wlen:= new_word.wlen;
            words.words(words.num_words).count:= new_word.count;
            words.words(words.num_words).countLN:= new_word.countLN;
            words.words(words.num_words).occursAtLine:= new_word.occursAtLine;
         end if;
         found:= False;
      end insert_word;

      proc_words: Word_List;
      letterFoundIndex: Natural:= 1;
      letter_counter: Natural:= 0;
      found_word: Word;
      found_length: Natural;
   begin
      -- Loop through all lines
      for i in 1 .. words.num_words loop
         -- put("word: " & words.words(i).s(1 .. 15));
         -- put_line(words.words(i).occursAtLine(1)'Image);
         -- Loop through letters in line
         for j in 1 .. words.words(i).wlen loop
            if words.words(i).s(j) = ' ' then
               found_word.wlen:= j - letterFoundIndex;
               found_word.s(1 .. words.words(i).s(letterFoundIndex ..
                            (j - 1))'length):= words.words(i).
                 s(letterFoundIndex .. (j - 1));
               found_word.count:= words.words(i).count;
               found_word.countLN:= words.words(i).countLN;
               found_word.occursAtLine:= words.words(i).occursAtLine;
               insert_word(found_word, proc_words);
               letterFoundIndex:= j + 1;
            end if;
            letter_counter:= letter_counter + 1;
         end loop;
         -- After new line
         if letter_counter > 0 then
            found_length:= letter_counter - (letterFoundIndex) + 1;
            found_word.wlen:= found_length;
            found_word.s(1 .. found_length):= words.words(i).s(letterFoundIndex .. letter_counter);
            found_word.count:= words.words(i).count;
            found_word.countLN:= words.words(i).countLN;
            found_word.occursAtLine:= words.words(i).occursAtLine;
            -- put(found_word.s(1 .. 4));
            -- put_line(found_word.countLN'Image);
            -- put_line(found_word.occursAtLine(1)'Image);
            -- put_line(found_word.occursAtLine(2)'Image);
            insert_word(found_word, proc_words);
            letter_counter:= 0;
            letterFoundIndex:= 1;
         end if;
      end loop;
      words:= proc_words;
   end strip_spaces;

   procedure quicksort(words: in out Word_Array; lo: Integer; hi: Integer) is
      -- Swap word a with word b
      procedure swap_words(a: in out Word; b: in out Word) is
         tmp_word: Word;
      begin
         tmp_word:= a;
         a:= b;
         b:= tmp_word;
      end;

      -- Quicksort helper which is the partition function
      function partition(words: in out Word_Array; lo: Integer; hi: Integer) return Integer is
         pivot: Word;
         i: Integer;
      begin
         pivot:= words(hi);
         i:= lo - 1;
         for j in lo .. (hi - 1) loop
            if (words(j).s <= pivot.s) then
               i:= i + 1;
               swap_words(words(i), words(j));
            end if;
         end loop;
         swap_words(words(i+1), words(hi));
         return (i + 1);
      end;

      p: Integer;
   begin
      if lo < hi then
         p:= partition(words, lo, hi);
         quicksort(words, lo, p - 1);
         quicksort(words, p + 1, hi);
      end if;
   end quicksort;

   procedure put_words(wl: Word_List) is
   begin
      for i in 1 .. wl.num_words loop
         put(wl.words(i).count);
         put(" " & wl.words(i).s(1 .. wl.words(i).wlen));
         new_line;
      end loop;
   end put_words;

   procedure print_file(words: Word_list) is
      output: File_Type;
   begin
      put("Printing to output.txt...");
      -- Prepare the output file
      create(File => output,
             Name => "output.txt");

      for i in 1 .. words.num_words loop
         put(File => output, 
             Item => words.words(i).s(1 .. words.words(1).wlen));
         put(File => output,
             Item => ": in lines");
         for k in 1 .. words.words(i).countLN loop
            put(File => output,
                Item => words.words(i).occursAtLine(k)'Image);
            put(File => output,
                Item => ",");
         end loop;
         put(File => output,
             Item => " wc =");
         put_line(File => output,
             Item => words.words(i).count'Image);
      end loop;
      close(output);
   end print_file;

   procedure test_arrays(wl: in out Word_List) is
   begin
      for i in 1 .. wl.num_words loop
         for k in 1 .. wl.words(i).countLN loop
            put(wl.words(i).occursAtLine(k)'Image);              
         end loop;
         put_line(" " & wl.words(i).s(1 .. 20));
      end loop;
   end test_arrays;

   the_words: Word_List;
begin
   read_file(the_words);
   strip_spaces(the_words);
   quicksort(the_words.words, 1, the_words.num_words);
   test_arrays(the_words);
   print_file(the_words);
end;
