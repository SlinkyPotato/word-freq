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

   -- Return true if a <= b, else false
   function word_less_than_equal(a: Word; b: Word) return Boolean is
   begin
      for i in 1 .. a.wlen loop
         if (a.s < b.s) then
            put("True:"); new_line;
            put("a: " & a.s); new_line;
            put("b: " & b.s); new_line;
            return True;
         end if;
         if (a.s > b.s) then
            put("False:"); new_line;
            put("a: " & a.s); new_line;
            put("b: " & b.s); new_line;
            return False;
         end if;
      end loop;
      return False;
      end word_less_than_equal;

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

   the_words: Word_List;
begin
   get_words(the_words);
   quicksort(the_words.words, 1, the_words.num_words);
   put_words(the_words);
end;
