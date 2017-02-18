-- Read one word per line and print list of unique words and their frequencies
-- Case sensitive
-- This is a minimalist version.  No bells or whistles.
with ada.integer_text_io; use ada.integer_text_io;
with ada.text_io; use ada.text_io;

procedure main  is
   type Word is record
      s: String(1 .. 120);  -- The string.  Assume 120 characters or less
      wlen: Natural;        -- Length of the word
      count: Natural := 0;  -- Total number of occurrences of this word
   end record;

   type Word_Array is array(1 .. 1000) of Word;

   type Word_List is record
      words: Word_Array;        --  The unique words
      num_words: Natural := 0;   --  How many unique words seen so far
   end record;

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
      begin
         -- Check if words list is empty, if so exit
         if (words.num_words = 0) then
            words.words(1).s(1 .. new_word.wlen):= new_word.s(1 .. new_word.wlen);
            words.num_words:= 1;
            words.words(1).count:= new_word.count;
            words.words(1).wlen:= new_word.wlen;
            found:= True;
         else
            for i in 1 .. words.num_words loop
               if (new_word.s = words.words(i).s) then
                  found:= True;
                  words.words(i).count:= new_word.count + words.words(i).count;
               end if;
            end loop;
         end if;
         if not found then
            words.num_words:= words.num_words + 1;
            words.words(words.num_words).s(1 .. new_word.wlen):= new_word.s(1 .. new_word.wlen);
            words.words(words.num_words).wlen:= new_word.wlen;
            words.words(words.num_words).count:= new_word.count;
         end if;
      end insert_word;

      proc_words: Word_List;
      letterFoundIndex: Natural:= 1;
      letter_counter: Natural:= 0;
      found_word: Word;
      found_length: Natural;
   begin
      -- Loop through all lines
      for i in 1 .. words.num_words loop
         -- Loop through letters in line
         for j in 1 .. words.words(i).wlen loop
            if words.words(i).s(j) = ' ' then
               found_word.wlen:= j - letterFoundIndex;
               found_word.s(1 .. words.words(i).s(letterFoundIndex ..
                            (j - 1))'length):= words.words(i).
                 s(letterFoundIndex .. (j - 1));
               found_word.count:= words.words(i).count;
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

   procedure print_words(words: Word_List) is
   begin
      put("Begin printing words:"); new_line;
      put(words.words(1).s); new_line;
      put(words.words(2).s); new_line;
      put("Number of words: "); put(words.num_words); new_line;
      --put(words.words(2).s); new_line;
      --put(words.words(3).s); new_line;
   end print_words;

   the_words: Word_List;
begin
   get_words(the_words);
   strip_spaces(the_words);
   quicksort(the_words.words, 1, the_words.num_words);
   put_words(the_words);
end;
